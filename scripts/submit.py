#! /usr/bin/env python3

import requests
import os
import argparse
import sys
import re

API_URL = "https://grade.bupt-hpc.cn"
SUBMISSION_ENDPOINT = "/api/homework/<id>/submit"


def parse_arguments():
    """Parse command line arguments."""
    # fmt: off
    parser = argparse.ArgumentParser(description="Submit CS101 lab assignments.")
    parser.add_argument("--lab", required=True, type=str, help="Lab to submit (e.g., lab1, lab2, lab3)")
    parser.add_argument("--token", required=True, type=str, help="Authentication token")
    parser.add_argument("--file", required=True, type=str, help="Path to the zip file to submit")
    # fmt: on
    return parser.parse_args()


def get_homework_id(lab: str) -> int:
    """Get the homework ID based on the lab name."""
    homework_ids = {
        "lab1": 1,
        "lab2": 2,
        "lab3": 3,
    }
    return homework_ids.get(lab, 1)


def submit(zip_path: str, token: str, url: str, endpoint: str) -> None:
    """Submit the zip file to the remote server."""
    if not os.path.exists(zip_path):
        print(f"Error: The file {zip_path} does not exist.")
        sys.exit(1)

    with open(zip_path, "rb") as f:
        files = {"file": f}
        headers = {"Authorization": f"Bearer {token}"}
        response = requests.post(url + endpoint, files=files, headers=headers)

    if response.status_code == 200:
        print("Submission successful!")
    else:
        print(f"Error: {response.status_code} - {response.text}")


def main():
    args = parse_arguments()
    endpoint = re.sub(r"<id>", str(get_homework_id(args.lab)), SUBMISSION_ENDPOINT)
    submit(args.file, args.token, API_URL, endpoint)


if __name__ == "__main__":
    main()
