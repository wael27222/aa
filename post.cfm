<cfscript>
    // Helper function to close JDBC resources safely
    function safeClose(obj) {
        if (isObject(obj) && structKeyExists(obj, "close")) {
            try {
                obj.close();
            } catch (any e) {
                // ignore close errors
            }
        }
    }
</cfscript>

<!--- Form for connection info and SQL input --->
<form method="post" style="width: 650px; margin-bottom: 30px;">
    <fieldset style="padding: 10px;">
        <legend><b>PostgreSQL Connection Info</b></legend>
        <label>IP Address:</label><br>
        <input type="text" name="dsn_ip" value="#htmlEditFormat(trim(form.dsn_ip))#" required><br><br>

        <label>Port:</label><br>
        <input type="number" name="dsn_port" value="#htmlEditFormat(trim(form.dsn_port ?: '5432'))#" required><br><br>

        <label>Database Name:</label><br>
        <input type="text" name="dsn_database" value="#htmlEditFormat(trim(form.dsn_database))#" required><br><br>

        <label>Username:</label><br>
        <input type="text" name="dsn_user" value="#htmlEditFormat(trim(form.dsn_user))#" required><br><br>

        <label>Password:</label><br>
        <input type="password" name="dsn_password" value="#htmlEditFormat(trim(form.dsn_password))#" required><br>
    </fieldset>

    <fieldset style="padding: 10px; margin-top: 20px;">
        <legend><b>SQL Command</b></legend>
        <textarea name="sqlCommand" rows="6" cols="75" required>#htmlEditFormat(trim(form.sqlCommand))#</textarea>
    </fieldset>

    <br>
    <input type="submit" value="Execute SQL" style="padding: 8px 20px; font-weight: bold;">
</form>

<cfif structKeyExists(form, "sqlCommand") AND len(trim(form.sqlCommand)) AND
      structKeyExists(form, "dsn_ip") AND len(trim(form.dsn_ip)) AND
      structKeyExists(form, "dsn_port") AND len(trim(form.dsn_port)) AND
      structKeyExists(form, "dsn_database") AND len(trim(form.dsn_database)) AND
      structKeyExists(form, "dsn_user") AND len(trim(form.dsn_user)) AND
      structKeyExists(form, "dsn_password")>

    <cftry>
        <cfscript>
            // Load PostgreSQL JDBC Driver
            driverClass = "org.postgresql.Driver";
            driver = createObject("java", driverClass);
            
            // JDBC connection string
            jdbcUrl = "jdbc:postgresql://" & trim(form.dsn_ip) & ":" & trim(form.dsn_port) & "/" & trim(form.dsn_database);

            // Get DriverManager class for connection
            DriverManager = createObject("java", "java.sql.DriverManager");

            // Open connection
            conn = DriverManager.getConnection(jdbcUrl, trim(form.dsn_user), trim(form.dsn_password));

            // Create statement
            stmt = conn.createStatement();

            sqlLower = lcase(trim(form.sqlCommand));
            firstWord = listFirst(sqlLower, " ");

            // Decide if query or update
            if (firstWord == "select" OR firstWord == "show" OR firstWord == "with") {
                // Execute Query
                rs = stmt.executeQuery(trim(form.sqlCommand));
                
                // Get metadata for columns
                meta = rs.getMetaData();
                columnCount = meta.getColumnCount();
                
                // Build results array to hold query data
                resultsArray = [];
                
                while (rs.next()) {
                    row = {};
                    for (i = 1; i <= columnCount; i++) {
                        colName = meta.getColumnLabel(i);
                        row[colName] = rs.getObject(i);
                    }
                    arrayAppend(resultsArray, row);
                }
            } else {
                // Execute Update
                updateCount = stmt.executeUpdate(trim(form.sqlCommand));
            }
        </cfscript>

        <h3>SQL Command Executed Successfully!</h3>

        <cfif structKeyExists(variables, "resultsArray") AND arrayLen(resultsArray) gt 0>
            <table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse;">
                <tr>
                    <cfloop index="i" from="1" to="#columnCount#">
                        <th>#htmlEditFormat(meta.getColumnLabel(i))#</th>
                    </cfloop>
                </tr>
                <cfloop index="row" array="#resultsArray#">
                    <tr>
                        <cfloop index="i" from="1" to="#columnCount#">
                            <td>#htmlEditFormat(row[meta.getColumnLabel(i)])#</td>
                        </cfloop>
                    </tr>
                </cfloop>
            </table>
        <cfelseif structKeyExists(variables, "updateCount")>
            <p>#updateCount# row(s) affected.</p>
        <cfelse>
            <p>No results returned.</p>
        </cfif>

        <cfscript>
            // Close JDBC objects safely
            safeClose(rs);
            safeClose(stmt);
            safeClose(conn);
        </cfscript>

        <cfcatch type="any">
            <p style="color:red;"><strong>Error executing SQL:</strong> #cfcatch.message#</p>
        </cfcatch>
    </cftry>
</cfif>
