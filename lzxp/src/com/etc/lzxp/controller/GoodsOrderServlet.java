package com.etc.lzxp.controller;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.etc.lzxp.entity.Goods_order;
import com.etc.lzxp.service.GoodsOrderService;
import com.etc.util.PageData;
import com.google.gson.Gson;

/**
 * Servlet implementation class GoodsOrderServlet
 * ��������Servlet
 */
@WebServlet("/GoodsOrderServlet")
public class GoodsOrderServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doPost(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		//����������Ӧ����
		request.setCharacterEncoding("UTF-8");
		response.setCharacterEncoding("UTF-8");
		//����jason��ʽ����
		response.setContentType("application/json");
		PrintWriter out= response.getWriter();
		PageData<Goods_order> pd = new PageData<>();
		//��ʼ��ҳ��
		int page = 1;
		int pageSize = 5;
		
		GoodsOrderService gos = new GoodsOrderService();
		
		if (request.getParameter("op")!=null) {
			//��ȡop
			String op = request.getParameter("op");
			
			if ("showAll".equals(op)) {
				/**
				 * ��ʾ���ж���
				 */
				if (request.getParameter("page")!=null) {
					page= Integer.parseInt(request.getParameter("page"));
				}
				if (request.getParameter("pageSize")!=null) {
					page= Integer.parseInt(request.getParameter("pageSize"));
				}
				//����gos�ķ���
				
				
			}
		
		
		
		
		}
		
	}
	
	
	//ajax��ӡ
	private void printJson(PrintWriter out,Object result){
		//����Json
		Gson gson = new Gson();
		//ת����Json��ʽ
		String str = gson.toJson(result);
		//��ӡ
		out.print(str);
		//�ͷ���Դ
		out.close();
	}

}