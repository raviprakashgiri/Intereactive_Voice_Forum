<%@page import="com.iitb.KookooFunctionsTextToSpeechModel.ProcessOrder"%>
<%@page import="com.iitb.MessageModel.DownloadFile"%>
<%@page import="com.iitb.dbUtilities.DataService"%>
<%@page import="com.iitb.globals.ConfigParams"%>
<%@page import="com.ozonetel.kookoo.Response,java.util.Date,com.ozonetel.kookoo.Record"%>
<%@page import= "java.sql.*"%>
<%@page import="com.ozonetel.kookoo.CollectDtmf"%>
<%@page import="java.util.Arrays"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
Response responsetype_response= new Response(); 
CollectDtmf cd = new CollectDtmf();
cd.setMaxDigits(1);
// 8000 = 8sec wait for collect DTMF
cd.setTimeOut(8000);
String language=request.getParameter("language");
System.out.println("langgg="+language);
String responsetype = request.getParameter("Responsetype");	
System.out.println("rstypeh=="+responsetype);
String groups_id = request.getParameter("groups_id");
String register_number = request.getParameter("register_number");
// for language we set base =1
char base = '1';

String number[] ={ConfigParams.DEFAULTWAV+"/default_wav/hi_one.wav",ConfigParams.DEFAULTWAV+"/default_wav/hi_two.wav",ConfigParams.DEFAULTWAV+"/default_wav/hi_three.wav"};
String response_type[]= {ConfigParams.PUBLICLINKFORAUDIO+"/language/hindi/hi_semi_structured.wav",ConfigParams.PUBLICLINKFORAUDIO+"/language/hindi/hi_unstructured.wav",ConfigParams.PUBLICLINKFORAUDIO+"/language/hindi/hi_structured.wav"};
String response_url[]={"OrderMenu_UnRegisterUser.jsp&language="+language+"&groups_id="+groups_id+"&register_number="+register_number,"Feedback_UnRegisterUser.jsp?event=NewCall&language="+language+"&groups_id="+groups_id+"&register_number="+register_number, "Response_UnregisterUser.jsp?event=NewCall&language="+language+"&groups_id="+groups_id+"&register_number="+register_number};
//responsetype convert into char array
char char_response[] = responsetype.toCharArray();
//char array store in sorted foam
Arrays.sort(char_response);
System.out.println(char_response);
%>
<c:choose> 
    <c:when test='${param.event == "NewCall" }'> 
        <%--When we get a new call,we have to prompt for voice--%>
        <%
        
       //only for one reponse
        if(char_response.length == 1){
        String extraUrl = response_url[char_response[0]-'1'];
        System.out.println(extraUrl);
        responsetype_response.addGotoNEXTURL(ConfigParams.getIvrslink()+extraUrl);
            out.print(responsetype_response.getXML());
        }
        // more then two response
        else {
        String voice="";
            for (int i=1;i<=responsetype.length();i++){
            	responsetype_response.addPlayAudio(response_type[char_response[i-1] - base]);
               	responsetype_response.addPlayAudio(ConfigParams.DEFAULTWAV+"/default_wav/hi_for.wav");
            	responsetype_response.addPlayAudio(number[i-1]);
            	responsetype_response.addPlayAudio(ConfigParams.DEFAULTWAV+"/default_wav/hi_press.wav");
            	
                }
           
         responsetype_response.addCollectDtmf(cd);
        session.setAttribute("state", "collectNumber");
        responsetype_response.addGotoNEXTURL(ConfigParams.getIvrslink()+"IncomingCallHindi_UnRegistered.jsp?Responsetype="+responsetype+"&language="+language+"&groups_id="+groups_id);
        out.print(responsetype_response.getXML());
        System.out.println("end3");
        }
        
        %>
    </c:when>
    
   <c:when test='${param.event == "GotDTMF" || requestScope.state == "collectNumber"}' >
   
   <%
   System.out.println("In side the DTMF");
   try{
   
	   String input_response  = request.getParameter("data");
       int length = responsetype.length();
     //interpreting the selected option
     
       if(input_response.equals(null)||input_response.equals("")||input_response==null||input_response==""){
    	
    	   responsetype_response.addPlayAudio(ConfigParams.DEFAULTWAV+"/default_wav/hi_provide_valid_input.wav");
       	   responsetype_response.addGotoNEXTURL(ConfigParams.getIvrslink()+"IncomingCallHindi_UnRegistered.jsp?Responsetype="+responsetype+"&language="+language+"&groups_id="+groups_id);
       }
       else if(Integer.parseInt(input_response)<=length){
    	   
	       String extraUrl = response_url[char_response[Integer.parseInt(input_response)-1]-'1'];
	       System.out.println(ConfigParams.getIvrslink()+extraUrl+"&language="+language);
	       responsetype_response.addGotoNEXTURL(ConfigParams.getIvrslink()+extraUrl+"&language="+language);
       }
       else{
    	   
    	   responsetype_response.addPlayAudio(ConfigParams.DEFAULTWAV+"/default_wav/hi_provide_valid_input.wav");
    	   responsetype_response.addGotoNEXTURL(ConfigParams.getIvrslink()+"IncomingCallHindi_UnRegistered.jsp?event=NewCall&Responsetype="+responsetype+"&language="+language+"&groups_id="+groups_id);
       }
       
    	 
       out.print(responsetype_response.getXML());
   }
   catch(Exception e){
      
	   System.out.println(e);
   }
   
   
   %>
        </c:when>
    
  </c:choose>