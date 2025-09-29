<cfscript>
    dsn_ip       = "10.0.5.141";
    dsn_port     = "6432";
    dsn_user     = "postgres";
    dsn_password = "ohvg2014";
    dsn_dns      = "db01";
</cfscript>


<!--- SQL input form --->
<form method="post">
    <label for="sqlCommand">Enter SQL Command:</label><br>
    <textarea id="sqlCommand" name="sqlCommand" rows="6" cols="70" placeholder="e.g. SELECT * FROM your_table LIMIT 10;"></textarea><br><br>
    <input type="submit" value="Execute SQL">
</form>

<cfif structKeyExists(form, "sqlCommand") AND len(trim(form.sqlCommand))>
    <cftry>
        <cfquery name="result" datasource="#dsn_dns#">
            #form.sqlCommand#
        </cfquery>

        <cfset sqlLower = lcase(trim(form.sqlCommand))>
        <cfset firstWord = listFirst(sqlLower, " ")>

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
