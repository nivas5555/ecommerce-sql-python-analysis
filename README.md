# Ecommerce SQL + Python Analysis

End-to-end eCommerce data analysis project using **Python for data preparation** and **MySQL for analytics**.

This project demonstrates a **real-world, production-style workflow** where Python and SQL are used together — each for what it does best.

---

## 📌 Project Overview

- **Python** → Data loading, validation, and format conversion  
- **MySQL** → Scalable querying, joins, aggregations, and window functions  

The dataset was originally provided in **Excel format**.  
Python was used to convert and prepare the data into clean CSV files for efficient database ingestion.

---

## ⚙️ Tools & Technologies

- Python (Pandas, NumPy)
- Jupyter Notebook
- MySQL / MySQL Workbench
- SQL (Joins, CTEs, Window Functions)
- Git & GitHub

---

## 📂 Repository Structure
ecommerce-sql-python-analysis/
│
├── data/ # Raw datasets (Excel / CSV)
├── output/ # Cleaned CSV files for SQL ingestion
├── notebooks/ # Python data preparation notebook
├── ecommerce_sql_analysis.sql
└── README.md

---

## 🧠 Why Python + SQL?

Python is excellent for:
- Reading Excel files
- Data validation
- File format conversion
- Automation

SQL is ideal for:
- Large-scale querying
- Business analytics
- Aggregations and window functions
- Performance on big datasets

---

## 🚀 Data Ingestion Strategy

### Python-based ingestion (Demonstrated)
- Python code shows how data **can** be loaded into MySQL using `LOAD DATA LOCAL INFILE`
- Included for **learning and completeness**

### Final approach used in this project
- **MySQL `LOAD DATA INFILE` via MySQL Workbench**
- Chosen because:
  - Faster for large datasets
  - More reliable
  - Industry-standard practice

This decision is clearly documented in the notebook.

---

## 📊 Analysis Performed (SQL)

- Revenue trends (monthly & yearly)
- Seller performance ranking
- Customer retention analysis
- Product performance analysis
- Year-over-Year growth
- Top customers by yearly spend

All analytics queries are available in:
ecommerce_sql_analysis.sql

---

## 📓 Python Notebook

Notebook focuses on:
- OS-independent file handling
- Dataset loading
- Data validation
- CSV generation for SQL ingestion
- Documentation of ingestion decisions

File:
notebooks/01_data_preparation_python.ipynb

---

## ✅ Key Takeaway

This project mirrors **real-world data workflows**:
- Python for preparation
- SQL for analytics
- Clear trade-offs explained
- Reproducible and recruiter-friendly structure

---

## 👤 Author

**Nivas Kumar**
