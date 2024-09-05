#!/bin/bash -e

# To run this script, the configured AWS user MUST have credentials configured
# in credentials files (see: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
# This script needs some environment variables set.
# Ensure `AWS_ACCOUNT`, `AWS_DEFAULT_REGION`, `ENVIRONMENT`, `ECR`, `ECR_ACCESS_ROLE_NAME`, `ECR_TAG_NAME`, `LOWER_AWS_ACCOUNT`, `LOWER_AWS_DEFAULT_REGION`, `LOWER_BRANCH`, `LOWER_ECR`, and `LOWER_ECR_ACCESS_ROLE_NAME` are correct.

promote_image() {
	# Defined some useful colors for echo outputs.
	# Use blue for informational.
	local blue="\033[1;34m"
	# Use yellow for warning informational.
	local yellow="\033[1;33m"
	# Use red for error informational and extreme actions.
	local red="\033[1;31m"
	# No Color (used to stop or reset a color).
	local nc='\033[0m'

	# Check if environment variables are NOT set.
	local empty=""
	if [[ -z "${AWS_ACCOUNT}" ]]; then
		empty+="AWS_ACCOUNT "
	fi
	if [[ -z "${AWS_DEFAULT_REGION}" ]]; then
		empty+="AWS_DEFAULT_REGION "
	fi
	if [[ -z "${ENVIRONMENT}" ]]; then
		empty+="ENVIRONMENT "
	fi
	if [[ -z "${ECR}" ]]; then
		empty+="ECR "
	fi
	if [[ -z "${ECR_ACCESS_ROLE_NAME}" ]]; then
		empty+="ECR_ACCESS_ROLE_NAME "
	fi
	if [[ -z "${ECR_TAG_NAME}" ]]; then
		empty+="ECR_TAG_NAME "
	fi
	if [[ -z "${LOWER_AWS_ACCOUNT}" ]]; then
		empty+="LOWER_AWS_ACCOUNT "
	fi
	if [[ -z "${LOWER_AWS_DEFAULT_REGION}" ]]; then
		empty+="LOWER_AWS_DEFAULT_REGION "
	fi
	if [[ -z "${LOWER_BRANCH}" ]]; then
		empty+="LOWER_BRANCH "
	fi
	if [[ -z "${LOWER_ECR}" ]]; then
		empty+="LOWER_ECR "
	fi
	if [[ -z "${LOWER_ECR_ACCESS_ROLE_NAME}" ]]; then
		empty+="LOWER_ECR_ACCESS_ROLE_NAME "
	fi
	if [[ -n "${empty}" ]]; then
		echo >&2 -e "${red}The environment variables ${yellow}${empty}${red}are empty!${nc}"
		exit 1
	fi

	local usage_only=false

	# Get values from environment variables.
	local aws_account=${AWS_ACCOUNT}
	local aws_default_region=${AWS_DEFAULT_REGION}
	local environment=${ENVIRONMENT}
	local ecr=${ECR}
	local ecr_access_role_name=${ECR_ACCESS_ROLE_NAME}
	local ecr_tag_name=${ECR_TAG_NAME}
	local lower_aws_account=${LOWER_AWS_ACCOUNT}
	local lower_aws_default_region=${LOWER_AWS_DEFAULT_REGION}
	local lower_branch=${LOWER_BRANCH}
	local lower_ecr=${LOWER_ECR}
	local lower_ecr_access_role_name=${LOWER_ECR_ACCESS_ROLE_NAME}

	local timestamp=""
	timestamp="$(date -u +"%Y%m%d%H%M%S")"
	local tag_prefix="${ecr_tag_name}-${environment}"
	local latest_tag="${tag_prefix}-latest"
	local unique_tag="${tag_prefix}-${timestamp}"
	local role_arn=arn:aws:iam::${aws_account}:role/${ecr_access_role_name}
	local lower_role_arn=arn:aws:iam::${lower_aws_account}:role/${lower_ecr_access_role_name}
	local lower_tag="${ecr_tag_name}-${lower_branch}-latest"
	local tags=""
	local latest_tag_with_timestamp=""

	# Get the absolute path of the current script
	local script_path=""
	script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

	local ecr_uri=${aws_account}.dkr.ecr.${aws_default_region}.amazonaws.com
	local image_uri=${ecr_uri}/${ecr}
	local lower_ecr_uri=${lower_aws_account}.dkr.ecr.${lower_aws_default_region}.amazonaws.com
	local lower_image_uri=${lower_ecr_uri}/${lower_ecr}

	# shellcheck source=/dev/null
	source "${script_path}"/general/options_helpers.sh

	# Function to display script usage
	usage() {
		usage_only=true
		echo >&2 -e "${blue}Usage: $0 [OPTIONS]${nc}"
		echo ""
		echo >&2 -e "${blue}Options:${nc}"
		echo >&2 -e "${blue} -h, --help          Display this message${nc}"
		echo ""
		echo >&2 -e "${blue}Required Environment Variables:${nc}"
		echo >&2 -e " - ${blue}AWS_ACCOUNT${nc}"
		echo >&2 -e " - ${blue}AWS_DEFAULT_REGION${nc}"
		echo >&2 -e " - ${blue}ENVIRONMENT${nc}"
		echo >&2 -e " - ${blue}ECR${nc}"
		echo >&2 -e " - ${blue}ECR_ACCESS_ROLE_NAME${nc}"
		echo >&2 -e " - ${blue}ECR_TAG_NAME${nc}"
		echo >&2 -e " - ${blue}LOWER_AWS_ACCOUNT${nc}"
		echo >&2 -e " - ${blue}LOWER_AWS_DEFAULT_REGION${nc}"
		echo >&2 -e " - ${blue}LOWER_BRANCH${nc}"
		echo >&2 -e " - ${blue}LOWER_ECR${nc}"
		echo >&2 -e " - ${blue}LOWER_ECR_ACCESS_ROLE_NAME${nc}"
	}

	# Handle options and arguments
	while [ $# -gt 0 ]; do
		case $1 in
		-h | --help)
			usage
			exit 0
			;;
		esac
		shift
	done

	if [ "$usage_only" = false ]; then
		# Start clean
		# shellcheck source=/dev/null
		source "${script_path}"/general/aws_unset.sh

		# Assume the access role for the lower environment ECR
		# shellcheck source=/dev/null
		source "${script_path}"/general/assume_ecr_write_access_role.sh --roleArn "${lower_role_arn}"

		echo >&2 -e "${blue}Logging in to the ${lower_branch} ECR.${nc}"
		aws ecr get-login-password --region "${lower_aws_default_region}" | docker login --username AWS --password-stdin "${lower_ecr_uri}"

		echo >&2 -e "${blue}Pulling ${lower_tag}.${nc}"

		if ! docker pull "${lower_image_uri}:${lower_tag}"; then
			echo >&2 -e "${red}Pulling failed.${nc}"
			exit 1
		fi

		# Get all tags for the Docker image that are associated with the `lower_tag`
		tags=$(aws ecr describe-images --repository-name "${lower_ecr}" --query "imageDetails[?imageTags[?contains(@,\`${lower_tag}\`)]].imageTags")

		if [ -z "$tags" ]; then
			echo >&2 -e "${red}Getting tags failed.${nc}"
			# Clean up
			source "${script_path}/general/aws_unset.sh"
			exit 1
		fi

		latest_tag_with_timestamp=$(echo "${tags}" | jq -r ".[] | map(select(. != \"${lower_tag}\")) | sort_by(split(\"-\")[-1] | tonumber) | reverse[0]")

		if [ -z "$latest_tag_with_timestamp" ]; then
			latest_tag_with_timestamp="${unique_tag}"
		else
			local stamp="${latest_tag_with_timestamp##*-}"
			latest_tag_with_timestamp="${tag_prefix}-${stamp}"
		fi

		# Clean up
		# shellcheck source=/dev/null
		source "${script_path}"/general/aws_unset.sh

		# Assume the access role for the ECR
		# shellcheck source=/dev/null
		source "${script_path}"/general/assume_ecr_write_access_role.sh --roleArn "${role_arn}"

		echo >&2 -e "${blue}Logging in to the ${environment} ECR.${nc}"
		aws ecr get-login-password --region "${aws_default_region}" | docker login --username AWS --password-stdin "${ecr_uri}"

		echo >&2 -e "${blue}Tagging ${lower_tag} with ${image_uri}:${latest_tag_with_timestamp}.${nc}"
		docker tag "${lower_image_uri}:${lower_tag}" "${image_uri}:${latest_tag_with_timestamp}"

		echo >&2 -e "${blue}Pushing ${image_uri}:${latest_tag_with_timestamp}.${nc}"
		docker push "${image_uri}:${latest_tag_with_timestamp}"

		echo >&2 -e "${blue}Tagging ${lower_tag} with ${image_uri}:${latest_tag}.${nc}"
		docker tag "${lower_image_uri}:${lower_tag}" "${image_uri}:${latest_tag}"

		echo >&2 -e "${blue}Pushing ${image_uri}:${latest_tag}.${nc}"
		docker push "${image_uri}:${latest_tag}"

		# Clean up
		# shellcheck source=/dev/null
		source "${script_path}"/general/aws_unset.sh
	fi
}

# Main script execution
promote_image "$@"
