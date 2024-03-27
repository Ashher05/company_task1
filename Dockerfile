# 1. Base Image: Start from a Python 3.9 image optimized for AWS Lambda
FROM public.ecr.aws/lambda/python:3.9

# 2. Copy Requirements File: Copy the requirements file to the Lambda task root
COPY requirements.txt ${LAMBDA_TASK_ROOT}

# 3. Copy Function Code: Copy the main Python function file to the task root
COPY task.py ${LAMBDA_TASK_ROOT}

# 4. Install Dependencies: Install Python packages listed in requirements.txt
RUN pip install -r requirements.txt

# 5. Set Entry Point: Specify the function to execute when the Lambda runs
CMD ["task.lambda_handler"]