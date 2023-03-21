#!/usr/bin/env python3
"""
Insert rows in the cars dynamodb table
"""

import boto3

TABLE_NAME = "CarsDemo"


def get_client():
    client = boto3.client('dynamodb')
    return client


def insert_rows() -> None:
    example_rows = [
        {"id": 1, "year": 2001, "make": "ACURA", "model": "CL"},
         {"id": 2, "year": 2001, "make": "ACURA", "model": "EL"},
         {"id": 3, "year": 2001, "make": "ACURA", "model": "INTEGRA"},
         {"id": 4, "year": 2001, "make": "ACURA", "model": "MDX"},
         {"id": 5, "year": 2001, "make": "ACURA", "model": "NSX"},
         {"id": 6, "year": 2001, "make": "ACURA", "model": "RL"},
         {"id": 7, "year": 2001, "make": "ACURA", "model": "TL"},
         {"id": 8, "year": 2001, "make": "AM GENERAL", "model": "HUMMER"},
         {"id": 9, "year": 2001, "make": "AMERICAN IRONHORSE", "model": "CLASSIC"},
         {"id": 10, "year": 2001, "make": "AMERICAN IRONHORSE", "model": "LEGEND"}
    ]

    client = get_client()

    for row in example_rows:
        item = {
            'id': {'S': str(row["id"])},
            'make': {'S': row["make"]},
            'model': {'S': row["model"]},
            'year': {'N': str(row["year"])}
        }

        try:
            client.put_item(TableName=TABLE_NAME, Item=item)
            print(f"PUT: {item}")
        except Exception as ex:
            print(f"Failed on item {item}")
            raise


def main():
    insert_rows()


if __name__ == '__main__':
    main()
