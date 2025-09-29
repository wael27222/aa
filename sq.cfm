<cfscript>
    dsn_ip       = "10.0.5.141";
    dsn_port     = "6432";
    dsn_user     = "postgres";
    dsn_password = "ohvg2014";
    dsn_dns      = "dns01";
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

        <cfset cleanedSQL = lcase(trim(form.sqlCommand))>
        <cfset firstWord = listFirst(cleanedSQL, " ")>

        <cfoutput>
            <h3>SQL Command Executed Successfully!</h3>

            <!--- If it's a SELECT statement, display results --->
            <cfif firstWord eq "select">
                <table border="1" cellpadding="5" cellspacing="0">
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
        </cfoutput>

        <cfcatch>
            <p style="color:red;">Error executing SQL: #cfcatch.message#</p>
        </cfcatch>
    </cftry>
</cfif>
