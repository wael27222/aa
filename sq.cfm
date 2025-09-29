<cfscript>
    dsn_ip       = "10.0.5.141";
    dsn_port     = "6432";
    dsn_user     = "postgres";
    dsn_password = "ohvg2014";
    dsn_dns      = "dns01";
    
    // Construct the datasource string for PostgreSQL
    // Usually, you configure a datasource in ColdFusion Administrator, but 
    // if you want to create a DSN-less connection, you can use cfqueryparam with a connection string.
</cfscript>

<!--- Form for SQL input --->
<form method="post">
    <label for="sqlCommand">Enter SQL Command:</label><br>
    <textarea id="sqlCommand" name="sqlCommand" rows="5" cols="60"></textarea><br><br>
    <input type="submit" value="Execute SQL">
</form>

<cfif structKeyExists(form, "sqlCommand") AND len(trim(form.sqlCommand))>
    <cftry>
        <!--- Execute the user input SQL command --->
        <cfquery name="result" datasource="#dsn_dns#">
            #form.sqlCommand#
        </cfquery>
        
        <cfoutput>
            <h3>SQL Command Executed Successfully!</h3>
            <!--- If it's a select statement, display results --->
            <cfif listFirst(lcase(trim(form.sqlCommand))) eq "select">
                <table border="1" cellpadding="5" cellspacing="0">
                    <tr>
                        <cfloop index="col" list="#result.columnList#">
                            <th>#col#</th>
                        </cfloop>
                    </tr>
                    <cfoutput query="result">
                        <tr>
                            <cfloop index="col" list="#result.columnList#">
                                <td>#result[col][currentRow]#</td>
                            </cfloop>
                        </tr>
                    </cfoutput>
                </table>
            <cfelse>
                <p>#result.recordCount# row(s) affected.</p>
            </cfif>
        </cfoutput>
        <cfcatch>
            <p style="color:red;">Error executing SQL: #cfcatch.message#</p>
        </cfcatch>
    </cftry>
</cfif>
