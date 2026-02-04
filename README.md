# Ecommerce SQL + Python Analysis

End-to-end eCommerce data analysis project using **Python for data preparation** and **MySQL for analytics**.

This project demonstrates a **real-world, production-style workflow** where Python and SQL are used together — each for what it does best.

---

## 📌 Project Overview

- **Python** → Data loading, validation, format conversion, and visualization  
- **MySQL** → Scalable querying, joins, aggregations, and window functions  

The dataset was originally provided in **Excel format**.  
Python was used to convert and prepare the data into clean CSV files for efficient database ingestion and downstream analytics.

---

## ⚙️ Tools & Technologies

- Python (Pandas, NumPy, Matplotlib, Seaborn)
- Jupyter Notebook
- MySQL / MySQL Workbench
- SQL (Joins, CTEs, Window Functions)
- Git & GitHub

---

## 📂 Repository Structure
data/ Raw ecommerce datasets
output/ SQL-derived analytical output tables
notebooks/ Python notebooks for data preparation and visualization
README.md End-to-end Python + SQL analytics workflow documentation
ecommerce_sql_analysis.sql Complete SQL analysis queries for ecommerce business insights


This structure is designed to be **clear, reproducible, and recruiter-friendly**, mirroring how analytics projects are organized in real production environments.

---

## Why Python + SQL?

**Python** is excellent for:
- Reading Excel files
- Data validation
- File format conversion
- Automation and visualization

**SQL** is ideal for:
- Large-scale querying
- Business analytics
- Aggregations and window functions
- Performance on large datasets

Using both together reflects **industry-standard analytics workflows**.

---

## Data Ingestion Strategy

### Python-based ingestion (Demonstrated)
- The notebook demonstrates how data **can be loaded into MySQL using Python**
- Included for **learning, transparency, and completeness**

### Final approach used in this project
- **MySQL `LOAD DATA INFILE` via MySQL Workbench**
- Chosen because:
  - Faster ingestion for large datasets
  - More reliable for bulk loading
  - Widely used in real-world data engineering workflows

This decision and trade-off are clearly documented in the notebook.

---

## Analysis Performed (SQL)

The following business analyses were performed entirely in SQL:

- Revenue trends (monthly & yearly)
- Seller performance ranking
- Customer retention analysis
- Product performance analysis
- Year-over-Year growth
- Top customers by yearly spend

All analytical queries are available in:
ecommerce_sql_analysis.sql

---

## Python Visual Analysis (Post-SQL)

Python is used for **visual storytelling and executive-level validation** of SQL insights, including:

- Monthly revenue trend
- Yearly revenue summary (executive view)
- Order value distribution
- Top customers by total order value
- Product price vs purchase frequency

All heavy analytics are performed in SQL; Python is used strictly for **communication and visualization**.

---

## Python Notebooks

The notebooks focus on:
- OS-independent file handling
- Dataset loading and validation
- CSV generation for SQL ingestion
- Visualization of SQL outputs
- Clear documentation of design decisions

Key notebooks:
- `01_data_preparation_python.ipynb`
- `02_visual_analysis_post_sql.ipynb`

---

## Key Takeaway

This project mirrors **real-world data workflows**:

- Python for preparation and visualization  
- SQL for analytics and business logic  
- Clear trade-offs explained  
- Clean, modular, and recruiter-friendly structure  

---

## 👤 Author

**Nivas Kumar**


