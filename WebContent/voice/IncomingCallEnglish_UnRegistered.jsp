<%@page import="com.iitb.KookooFunctionsTextToSpeechModel.ProcessOrder"%>
<%@page import="com.iitb.MessageModel.DownloadFile"%>
<%@page import="com.iitb.dbUtilities.DataService"%>
<%@page import="com.ozonetel.kookoo.Response,java.util.Date,com.ozonetel.kookoo.Record"%>
<%@page import= "java.sql.*"%>
<%@page import="com.ozonetel.kookoo.CollectDtmf"%>
 <%@page import="com.iitb.globals.ConfigParams"%>
 <%@page import="java.util.Arrays"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
CollectDtmf cd = new CollectDtmf();
// wait 8 sec for collect DTMF
cd.setTimeOut(8000);
cd.setMaxDigits(1);
Response responsetype_response= new Response();
String responsetype = request.getParameter("Responsetype");	 
System.out.println("rstypem=="+responsetype);
String language=request.getParameter("language");
String groups_id = request.getParameter("groups_id");
String register_number = request.getParameter("register_number");

String number[]={ConfigParams.DEFAULTWAV+"/default_wav/en_one.wav" , ConfigParams.DEFAULTWAV+"/default_wav/en_two.wav" , ConfigParams.DEFAULTWAV+"/default_wav/en_three.wav"};
String response_type[]= {ConfigParams.PUBLICLINKFORAUDIO+"/language/english/en_semi_structured.wav",ConfigParams.PUBLICLINKFORAUDIO+"/language/english/en_unstructured.wav",ConfigParams.PUBLICLINKFORAUDIO+"/language/english/en_structured.wav"};
String response_url[]={"OrderMenu_UnRegisterUser.jsp&language="+language+"&groups_id="+groups_id+"&register_number="+register_number,"Feedback_UnRegisterUser.jsp?event=NewCall&language="+language+"&groups_id="+groups_id+"&register_number="+register_number, "Response_UnregisterUser.jsp?event=NewCall&language="+language+"&groups_id="+groups_id+"&register_number="+register_number};

// responsetype convert into char array
char char_response[] = responsetype.toCharArray();

//char array store in sorted foam
Arrays.sort(char_response);
%>
<c:choose> 
    <c:when test='${param.event == "NewCall" }'> 
        <%--When we get a new call,we have to prompt for voice--%>
        <%
        
        // only for one response
      
        if(char_response.length == 1){
        	String extraUrl = response_url[char_response[0]-'1'];
        	System.out.println(extraUrl);
        	responsetype_response.addGotoNEXTURL(ConfigParams.getIvrslink()+extraUrl);
            out.print(responsetype_response.getXML());
        }
        // more then one response
        else {
        	String voice="";
            for (int i=1;i<=responsetype.length();i++){
        	
        		responsetype_response.addPlayAudio(ConfigParams.DEFAULTWAV+"/default_wav/en_press.wav");
        		responsetype_response.addPlayAudio(number[i-1]);
        		responsetype_response.addPlayAudio(ConfigParams.DEFAULTWAV+"/default_wav/en_for.wav");
               	responsetype_response.addPlayAudio(response_type[char_response[i-1] - '1']);
    
            }
           
          
            responsetype_response.addCollectDtmf(cd);
            responsetype_response.addGotoNEXTURL(ConfigParams.getIvrslink()+"IncomingCallEnglish_UnRegistered.jsp?Responsetype="+responsetype+"&language="+language+"&groups_id="+groups_id);
            out.print(responsetype_response.getXML());
        
        }
        
             %>
    </c:when>
    
   <c:when test='${param.event == "GotDTMF"|| requestScope.state1 == "collectNumber" }' >
   
   <%
   try{
	   String usernumber = request.getParameter("data");
	   int length = responsetype.length();
	   //interpreting the selected option
	   if(usernumber.equals(null)||usernumber.equals("")||usernumber==""||usernumber==null){
		   responsetype_response.addPlayAudio(ConfigParams.DEFAULTWAV+"/default_wav/en_provide_valid_input.wav");
		   responsetype_response.addGotoNEXTURL(ConfigParams.getIvrslink()+"IncomingCallEnglish_UnRegistered.jsp?event=NewCall&Responsetype="+responsetype+"&language="+language+"&groups_id="+groups_id);
	   }
	   
	   // check the length
	   else if(Integer.parseInt(usernumber)<=length){
       String extraUrl = response_url[char_response[Integer.parseInt(usernumber)-1]-'1'];
       System.out.println(extraUrl);
       responsetype_response.addGotoNEXTURL(ConfigParams.getIvrslink()+extraUrl+"language="+language);
	   }
	   else{
	
		   responsetype_response.addPlayAudio(ConfigParams.DEFAULTWAV+"/default_wav/en_provide_valid_input.wav");
		   responsetype_response.addGotoNEXTURL(ConfigParams.getIvrslink()+"IncomingCallEnglish_UnRegistered.jsp?event=NewCall&Responsetype="+responsetype+"&language="+language+"&groups_id="+groups_id);
		   
	   }
       out.print(responsetype_response.getXML());
   }
   
   catch(Exception e){
	   System.out.println(e);
       e.printStackTrace();
   }
   
   
   %>
        </c:when>
  </c:choose>