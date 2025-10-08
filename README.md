# Portfolio Projects

This repository contains a curated selection of data analysis and visualization projects created to showcase practical skills in Python, SQL, Excel, and Power BI. Each project is structured to be easy to explore and reproduce, with clear descriptions and the source artifacts (scripts, SQL, spreadsheets, and reports) included where applicable.

## Contents

- `sql_movie_data_analysis/` — SQL-based exploratory analysis of a movie dataset (includes `imdb_top_1000.csv` and `movie_data_analysis.sql`).
- Other folders may contain Python notebooks/scripts, Excel workbooks, and Power BI report files. Projects are grouped by technology and labelled with a short README when needed.

## Technologies & Skills Demonstrated

- Python: data cleaning, exploratory data analysis, visualization, and scripting for repeatable workflows.
- SQL: data extraction, aggregation, window functions, and writing reproducible analysis queries.
- Excel: structured analysis, pivot tables, formulas, and dashboarding for quick business insights.
- Power BI: interactive reports, data modelling, measures (DAX), and visual storytelling.

## Highlights

- Movie data analysis (SQL): A focused example demonstrating how to ingest a CSV dataset, perform exploratory queries, rank and aggregate movie information, and prepare the results for visualization or reporting. See `sql_movie_data_analysis/movie_data_analysis.sql` and `sql_movie_data_analysis/imdb_top_1000.csv` for the dataset and queries.

- COVID-19 data exploration (SQL): An end-to-end analytical exercise using the `CovidDeaths.csv` and `CovidVaccinations.csv` datasets (see `sql_covid_data_analysis/covid_data_exploration.sql`). The analysis demonstrates practical techniques for real-world data: joins between cases and vaccination tables, data cleansing and type conversion, rolling aggregates and window functions to compute cumulative vaccinations, use of CTEs and temporary tables for intermediate calculations, and the creation of views to support downstream visualizations. Example outputs include percentage of population infected, deaths per population, and percent of population vaccinated — all prepared for reporting or integration into Power BI dashboards.

- Other demonstrative work (Python/Excel/Power BI): Python notebooks and scripts illustrate data preparation and visualization workflows; Excel workbooks show pivot-table-driven analysis and dashboards; Power BI files (where included) present interactive reports built from prepared datasets.

## How to explore this repository

1. Clone or download the repository to your machine.
2. Inspect the folder structure and open project-level README files where present.
3. For SQL projects: open the `.sql` files in your preferred SQL client or a text editor. The `imdb_top_1000.csv` file is included as a sample dataset in `sql_movie_data_analysis/`.
4. For Python projects: use a virtual environment, install dependencies (if a `requirements.txt` is present), and run Jupyter notebooks or Python scripts.
	 - Example (optional):

		 ```powershell
		 python -m venv .venv; .\.venv\Scripts\Activate.ps1; pip install -r requirements.txt
		 ```

5. For Excel workbooks: open with Microsoft Excel or a compatible viewer.
6. For Power BI reports: open `.pbix` files with Power BI Desktop to interact with the visualizations.

## Contributing

This repository is intended to showcase individual portfolio work. If you would like to contribute enhancements or sample data, please open an issue or submit a pull request and include a short description of your proposed change.


Thank you for reviewing this portfolio. The projects here are designed to demonstrate a practical, end-to-end approach to data analysis: collecting and preparing data, extracting insights with SQL and Python, and presenting results with Excel and Power BI.