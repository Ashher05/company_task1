import boto3
import csv
import psycopg2

# AWS Region
AWS_REGION = 'ap-south-1'

# PostgreSQL connection details
PG_HOST = 'postgressql.cvocwcsqercq.ap-south-1.rds.amazonaws.com'
PG_DATABASE = 'postgres'
PG_USER = 'postgres'
PG_PASSWORD = 'ashher1234'
PG_PORT = '5432'

# S3 bucket and file details
BUCKET_NAME = 'godigital-task'
FILE_NAME = 'day.csv'

def lambda_handler(event, context):
    # Initialize S3 and PostgreSQL clients
    s3 = boto3.client('s3', region_name=AWS_REGION)
    conn = psycopg2.connect(host=PG_HOST, database=PG_DATABASE, user=PG_USER, password=PG_PASSWORD, port=PG_PORT)
    cursor = conn.cursor()
    
    try:
        # Download CSV file from S3
        with open('/tmp/' + FILE_NAME, 'wb') as f:
            s3.download_fileobj(BUCKET_NAME, FILE_NAME, f)
        
        # Insert data from CSV into PostgreSQL table
        with open('/tmp/' + FILE_NAME, 'r') as f:
            csv_reader = csv.reader(f)
            next(csv_reader)  # Skip header row
            for row in csv_reader:
                cursor.execute("""
                    INSERT INTO day (Numeric, "Numeric-2", "Numeric-Suffix") 
                    VALUES (%s, %s, %s)
                """, row)
        
        # Commit changes
        conn.commit()
        print("Data inserted successfully.")
        
        # Display data from PostgreSQL table
        cursor.execute("SELECT * FROM day")
        inserted_data = cursor.fetchall()
        for row in inserted_data:
            print(row)
    
    except Exception as e:
        print("Error:", e)
        conn.rollback()
    
    finally:
        # Close database connection
        cursor.close()
        conn.close()

# Adding a line to trigger the lambda_handler function
lambda_handler(None, None)
