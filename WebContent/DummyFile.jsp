<!DOCTYPE html >

<!-- 
Document : DummyFile.jsp

 -->
 
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="com.iitb.globals.*"%>

<jsp:useBean id="groupBean" class="com.iitb.GroupBean.GroupBean" scope="request" />
<jsp:useBean id="loginUser" class="com.iitb.AuthenticatorBean.LoginBean" scope="session" />
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	
	<script type="text/javascript" src="js/jquery-1.9.1.js"></script>
	<script type="text/javascript" src="Validate.js"></script>
	<script type="text/javascript" src="js/1.10.4.jquery-ui.js"></script>
	
	<link rel="stylesheet" href="css/jquery-ui.css">

<title>Add Groups</title>
</head>
		<%
			String memberNumber=request.getParameter("selectedGroup");
		System.out.println("memebrnumber"+memberNumber);
				String groupId=request.getParameter("groupId");
				System.out.println("groupId"+groupId);
		%>

<body target='content-iframe'>

<%
//This validation is for checking session
if(loginUser.getUsername()==null || loginUser.getParent_org()==null || loginUser.getOrg_id()==null)
{
	RequestDispatcher requestDispatcher=request.getRequestDispatcher("Login.jsp");  
    requestDispatcher.forward(request, response);  
}
%>

  <div id="uploadDialog">
 		<form ENCTYPE="multipart/form-data" action="IvrsServlet" method="POST" name="dummy_file_upload" id="newfileupload">
		
		<table>
		<tr>
			<td><input type="hidden" name="req_type" id = "req_type" value="dummyFileUpload"></td>
			<td><input type="hidden" name="memberNumber" value="<%=memberNumber%>"></td>
			<td><input type="hidden" name="groupId" value="<%=groupId%>"></td>
	        <td><input type="submit" value="Generate Dummy File" onclick="return SaveSettings4();" /></td>
		</tr>
		<tr class="new-file-upload-tr"></tr>
		</table>
		</form>
 </div> 
</body>
</html>
