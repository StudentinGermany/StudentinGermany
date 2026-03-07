# import sys
# import os
# import threading
# import time
# from datetime import datetime
#
# current_dir = os.path.dirname(os.path.abspath(__file__))
# parent_dir = os.path.dirname(current_dir)
# sys.path.append(parent_dir)
#
# WORK_DIR = "/Users/aydenyun/Documents/MailForge/csv_to_word_converter"
# CSV_PATH = os.path.join(WORK_DIR, "input.csv")
# DOCX_TEMPLATE = os.path.join(WORK_DIR, "input.docx")
# DOCX_OUTPUT = os.path.join(WORK_DIR, "output.docx")
#
# from fastapi import FastAPI
# from fastapi.middleware.cors import CORSMiddleware
# from fastapi.responses import FileResponse, JSONResponse
# from pydantic import BaseModel
# import threading
# import time
#
#
# from csv_to_word_converter.replace import csv_to_docx, update_csv_file, get_csv_data
#
# from email_generator import EmailDataGenerator
#
# app = FastAPI()
#
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_methods=["*"],
#     allow_headers=["*"],
# )
#
# class DocxPayload(BaseModel):
#     Gutacthen: str
#     NAME: str
#     DATE: str
#     LAW_FIRM: str
#
# # --- INITIALIZATION ---
# # Instance of the generator from gen.py
# my_generator = EmailDataGenerator(start_time=datetime(2026, 1, 1, 9, 0, 0))
# db_emails = []
#
# # --- HELPER FUNCTION ---
# # Return a tuple: (x0, x1, x2, x3, x4, x5)
# # a dictionary: { status: ..., deal_number: ... } JASON
# # This function bridges the two.
# def create_new_email_entry():
#     """
#     This function calls the new generator, saves the file,
#     and translates the data into the format your Frontend expects.
#     """
#
#     # 1. Generate the data & Save the HTML (produce_record does both)
#     raw_data = my_generator.produce_record()
#
#     # 2. Map the NEW data keys to the OLD keys your frontend uses
#     # Old x0 (0/1) -> New boolean needs to be converted to int
#     # Old x1 (-)   -> New None needs to be converted to "-"
#
#     status_int = 1 if raw_data["status_closed"] else 0
#     deal_num = raw_data["deal_reference"] if raw_data["deal_reference"] else "-"
#
#     return {
#         "status": status_int,  # Was x0
#         "deal_number": deal_num,  # Was x1
#         "sent_time": raw_data["timestamp"],  # Was x2
#         "sender": raw_data["sender_email"],  # Was x3
#         "subject": raw_data["email_subject"],  # Was x4
#         "html_path": raw_data["local_path"]  # Was x5 (e.g., "pool/123.html")
#     }
#
#
# # --- GENERATE INITIAL DATA --- for loop gen.py
# print("--- GENERATING INITIAL DATA FROM GEN.PY ---")
# for _ in range(10):
#     db_emails.insert(0, create_new_email_entry())
#
#
# # For while loop
# def run_background_loop():
#     print("--- Background Loop Started ---")
#     while True:
#         time.sleep(2) # Wait 2 seconds
#
#         # Use the existing function
#         new_item = create_new_email_entry()
#
#         # Add to the list
#         db_emails.insert(0, new_item)
#
#         # Keep list short if we need less than 50
#         # if len(db_emails) > 50:
#         #     db_emails.pop()
#
#         print(f"Auto-generated: {new_item['subject']}")
#
# # Start the loop in a separate thread so it doesn't block the server
# thread = threading.Thread(target=run_background_loop, daemon=True)
# thread.start()
#
# #API
#
# @app.get("/api/emails")
# def get_emails():
#     return db_emails
#
# @app.post("/api/refresh")
# def refresh_emails():
#     # Create new data using the bridge function
#     new_item = create_new_email_entry()
#
#     db_emails.insert(0, new_item)
#     if len(db_emails) > 50:
#         db_emails.pop()
#     return db_emails
#
# @app.get("/api/html-content")
# def get_html_content(path: str):
#     # Security check
#     if not path.startswith("pool/"):
#          return {"content": "<h1>Error: Invalid path</h1>"}
#
#     if os.path.exists(path):
#         with open(path, 'r', encoding='utf-8') as f:
#             return {"content": f.read()}
#     return {"content": "<h1>Error: File not found</h1>"}
#
# # @app.get("/api/html-content")
# # def get_html_content(path: str):
# #     if not path.startswith("mock_email_data/"):
# #         return {"content": "<h1>Error: Invalid path</h1>"}
# #
# #     if os.path.exists(path):
# #         with open(path, "r", encoding="utf-8") as f:
# #             return {"content": f.read()}
# #
# #     return {"content": "<h1>Error: File not found</h1>"}
#
# #2026.03.05
# # For the "AUTO" Button
# # Read the current state of input.csv and send it to the frontend
# @app.get("/api/get-csv-data")
# def read_csv():
#     data = get_csv_data(CSV_PATH)
#     return JSONResponse(content=data)
#
# # For "Download"
# # Updates CSV -> Generates Word -> Returns File
# @app.post("/api/generate-docx")
# def generate_docx(payload: DocxPayload):
#
#     # Update the CSV file with user input
#     success = update_csv_file(CSV_PATH, payload.model_dump())
#     if not success:
#         return {"error": "Failed to update CSV file"}
#
#     # Convert CSV to Word
#     csv_to_docx(DOCX_TEMPLATE, CSV_PATH, DOCX_OUTPUT)
#
#     # Return the file
#     return FileResponse(
#         DOCX_OUTPUT,
#         media_type="application/vnd.openxmlformats-officedocument.wordprocessingml.document",
#         filename=f"Gutacthen_{payload.Gutacthen}.docx"
#     )


import sys
import os
import threading
import time
from datetime import datetime

current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir)
sys.path.append(parent_dir)

WORK_DIR = "/Users/aydenyun/Documents/MailForge/csv_to_word_converter"
CSV_PATH = os.path.join(WORK_DIR, "input.csv")
DOCX_TEMPLATE = os.path.join(WORK_DIR, "input.docx")
DOCX_OUTPUT = os.path.join(WORK_DIR, "output.docx")

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, JSONResponse
from pydantic import BaseModel

# Ensure these are correctly imported from your project structure
from csv_to_word_converter.replace import csv_to_docx, update_csv_file, get_csv_data
from email_generator import EmailDataGenerator

app = FastAPI()

# FIX 1: Allow all origins and methods so the browser doesn't block it
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Changed from [""]
    allow_methods=["*"],  # Changed from [""]
    allow_headers=["*"],
)


class DocxPayload(BaseModel):
    Gutacthen: str
    NAME: str
    DATE: str
    LAW_FIRM: str


# --- INITIALIZATION ---
my_generator = EmailDataGenerator(start_time=datetime(2026, 1, 1, 9, 0, 0))
db_emails = []


# --- HELPER FUNCTION ---
def create_new_email_entry():
    raw_data = my_generator.produce_record()
    status_int = 1 if raw_data.get("status_closed") else 0
    deal_num = raw_data.get("deal_reference") if raw_data.get("deal_reference") else "-"

    return {
        "status": status_int,
        "deal_number": deal_num,
        "sent_time": raw_data.get("timestamp"),
        "sender": raw_data.get("sender_email"),
        "subject": raw_data.get("email_subject"),
        "html_path": raw_data.get("local_path")
    }


print("--- GENERATING INITIAL DATA FROM GEN.PY ---")
for _ in range(10):
    db_emails.insert(0, create_new_email_entry())


def run_background_loop():
    print("--- Background Loop Started ---")
    while True:
        time.sleep(2)
        new_item = create_new_email_entry()
        db_emails.insert(0, new_item)
        if len(db_emails) > 50:
            db_emails.pop()
        print(f"Auto-generated: {new_item['subject']}")


thread = threading.Thread(target=run_background_loop, daemon=True)
thread.start()


# --- API ROUTES ---

@app.get("/api/emails")
def get_emails():
    return db_emails


@app.post("/api/refresh")
def refresh_emails():
    new_item = create_new_email_entry()
    db_emails.insert(0, new_item)
    if len(db_emails) > 50:
        db_emails.pop()
    return db_emails


@app.get("/api/html-content")
def get_html_content(path: str):
    # Allow both pool/ and mock_email_data/
    if not (path.startswith("pool/") or path.startswith("mock_email_data/")):
        return {"content": "<h1>Error: Invalid path</h1>"}

    if os.path.exists(path):
        with open(path, 'r', encoding='utf-8') as f:
            return {"content": f.read()}
    return {"content": "<h1>Error: File not found</h1>"}


@app.get("/api/get-csv-data")
def read_csv():
    data = get_csv_data(CSV_PATH)
    return JSONResponse(content=data)


@app.post("/api/generate-docx")
def generate_docx(payload: DocxPayload):
    success = update_csv_file(CSV_PATH, payload.model_dump())
    if not success:
        return {"error": "Failed to update CSV file"}

    csv_to_docx(DOCX_TEMPLATE, CSV_PATH, DOCX_OUTPUT)

    return FileResponse(
        DOCX_OUTPUT,
        media_type="application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        filename=f"Gutacthen_{payload.Gutacthen}.docx"
    )