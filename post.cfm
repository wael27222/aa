<!--- Connection + SQL input form --->
<form method="post">
    <fieldset style="width: 600px; padding: 15px;">
        <legend><strong>Database Connection Info</strong></legend>
        <label for="dsn_ip">IP Address:</label><br>
        <input type="text" name="dsn_ip" id="dsn_ip" value="#form.dsn_ip#" required><br><br>

        <label for="dsn_port">Port:</label><br>
        <input type="text" name="dsn_port" id="dsn_port" value="#form.dsn_port#" required><br><br>

        <label for="dsn_database">Database Name:</label><br>
        <input type="text" name="dsn_database" id="dsn_database" value="#form.dsn_database#" required><br><br>

        <label for="dsn_user">Username:</label><br>
        <input type="text" name="dsn_user" id="dsn_user" value="#form.dsn_user#" required><br><br>

        <label for="dsn_password">Password:</label><br>
        <input type="password" name="dsn_password" id="dsn_password" value="#form.dsn_password#" required><br><br>
    </fieldset>
    <br>
    <fieldset style="width: 600px; padding: 15px;">
        <legend><strong>SQL Command</strong></legend>
        <textarea id="sqlCommand" name="sqlCommand" rows="6" cols="70" placeholder="e.g. SELECT * FROM your_table LIMIT 10;" required>#form.sqlCommand#</textarea><br><br>
    </fieldset>
    <br>
    <input type="submit" value="Execute SQL">
</form>

<cfif structKeyExists(form, "sqlCommand") AND len(trim(form.sqlCommand)) AND
      structKeyExists(form, "dsn_ip") AND len(trim(form.dsn_ip)) AND
      structKeyExists(form, "dsn_port") AND len(trim(form.dsn_port)) AND
      structKeyExists(form, "dsn_database") AND len(trim(form.dsn_database)) AND
      structKeyExists(form, "dsn_user") AND len(trim(form.dsn_user)) AND
      structKeyExists(form, "dsn_password")>

    <cftry>
        <cfscript>
            // Build JDBC connection string dynamically
            jdbcString = "jdbc:postgresql://" & trim(form.dsn_ip) & ":" & trim(form.dsn_port) & "/" & trim(form.dsn_database);
            sqlLower = lcase(trim(form.sqlCommand));
            firstWord = listFirst(sqlLower, " ");
        </cfscript>

        <cfquery name="result" dbtype="jdbc"
                 username="#trim(form.dsn_user)#"
                 password="#trim(form.dsn_password)#"
                 connectstring="#jdbcString#">
            #form.sqlCommand#
        </cfquery>

        <h3>SQL Command Executed Successfully!</h3>

        <cfif firstWord eq "select">
            <table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse;">
                <tr>
                    <cfloop index="col" list="#result.columnList#">
                        <th>#htmlEditFormat(col)#</th>
                    </cfloop>
                </tr>
                <cfoutput query="result">
                    <tr>
                        <cfloop index="col" list="#result.columnList#">
                            <td>#htmlEditFormat(result[col][currentRow])#</td>
                        </cfloop>
                    </tr>
                </cfoutput>
            </table>
        <cfelse>
            <p>#result.recordCount# row(s) affected.</p>
        </cfif>

        <cfcatch type="any">
            <p style="color:red;">
                <strong>Error executing SQL:</strong> #cfcatch.message#
            </p>
        </cfcatch>
    </cftry>
</cfif>
