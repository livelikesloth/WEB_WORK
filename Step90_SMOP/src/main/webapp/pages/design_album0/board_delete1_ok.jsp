<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@ page import="javax.naming.Context" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>

<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>

<%@ page import="java.io.File" %>

<%
	String uploadPath = "C:/Java/jsp-workspace/AlbumEx01/WebContent/upload";

	request.setCharacterEncoding( "utf-8" );

	String seq = request.getParameter( "seq" );
	String password = request.getParameter( "password" );
	
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	
	int flag = 2;
	try {
		Context initCtx = new InitialContext();
		Context envCtx = (Context)initCtx.lookup( "java:comp/env" );
		DataSource dataSource = (DataSource)envCtx.lookup( "jdbc/mariadb2" );
	
		conn = dataSource.getConnection();
		
		String sql = "select filename from album_board1 where seq=?"; 
		pstmt = conn.prepareStatement( sql );
		pstmt.setString( 1, seq );
		
		rs = pstmt.executeQuery();
		String filename = null;
		if( rs.next() ) {
			filename = rs.getString( "filename" );
		}
		
		pstmt.close();
		
		sql = "delete from album_board1 where seq=? and password=?";
		pstmt = conn.prepareStatement( sql );
		pstmt.setString( 1, seq );
		pstmt.setString( 2, password );

		int result = pstmt.executeUpdate();
		if( result == 0 ) {
			flag = 1;
		} else if( result == 1 ) {
			flag = 0;
			if( filename != null ) {
				File file = new File( uploadPath + "/" + filename );
				file.delete();
			}
		}
	} catch( NamingException e ) {
		System.out.println( "[에러] " + e.getMessage() );
	} catch( SQLException e ) {
		System.out.println( "[에러] " + e.getMessage() );
	} finally {
		if( pstmt != null ) pstmt.close();
		if( conn != null ) conn.close();
	}
	
	out.println( "<script type='text/javascript'>" );
	if( flag == 0 ) {
		out.println( "alert('글삭제에 성공했습니다.');" );
		out.println( "location.href='board_list1.jsp';" );
	} else if(flag == 1){
		out.println( "alert('비밀번호가 틀립니다.');" );
		out.println( "history.back();" );
	} else {
		out.println( "alert('글삭제에 실패했습니다.');" );
		out.println( "history.back();" );	
	}
	out.println( "</script>" );
%>
