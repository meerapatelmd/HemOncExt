# pg13::lsTables(conn = conn,
#                schema = "hemonc_extension")

conn <- chariot::connect_athena()
# pg13::send(conn = conn,
#            sql_statement = "DROP SCHEMA hemonc_extension CASCADE")


chariot::execute_athena_constraints()



download.file(url = "https://raw.githubusercontent.com/OHDSI/CommonDataModel/master/PostgreSQL/OMOP%20CDM%20postgresql%20constraints.txt",
              destfile = "constraints.txt")
