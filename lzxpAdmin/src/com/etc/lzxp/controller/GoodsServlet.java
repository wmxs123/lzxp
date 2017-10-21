package com.etc.lzxp.controller;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

import com.etc.lzxp.entity.Goods;
import com.etc.lzxp.entity.GoodsAndStype;
import com.etc.lzxp.entity.GoodsStypePicture;
import com.etc.lzxp.entity.Goods_stype;
import com.etc.lzxp.service.GoodsService;

/**
 * Servlet implementation class GoodsServlet
 */
@WebServlet("/GoodsServlet")
public class GoodsServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	 // �ϴ��ļ��洢Ŀ¼
    private static final String UPLOAD_DIRECTORY = "images";
 
    // �ϴ�����
    private static final int MEMORY_THRESHOLD   = 1024 * 1024 * 3;  // 3MB
    private static final int MAX_FILE_SIZE      = 1024 * 1024 * 40; // 40MB
    private static final int MAX_REQUEST_SIZE   = 1024 * 1024 * 50; // 50MB
 
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
		
		List<GoodsStypePicture> list =new ArrayList<GoodsStypePicture>();
		
		GoodsService gs= new GoodsService();
		
		String goodsName = null;
		String stypeName = null;
		double goodsPrice =1;
		String goodsContent = null;
		int goodsStock = 0;
		String fileName = "";//�ļ���
		String path ="";//�洢·��
		//�ϴ��ļ�
		DiskFileItemFactory factory = new DiskFileItemFactory();
		 
		ServletFileUpload upload = new ServletFileUpload(factory);
		
		if (request.getParameter("op") != null) {

			// ��op��ֵȡ���� �ж����ֵ
			String op = request.getParameter("op");

			if (op.equals("getAllGoods")) {
				// ��ѯ���У�����Service�еķ��� 
				list = gs.getAllGoods();

			}   else if (op.equals("addGoods")) {
				/**
				 * ������Ʒ
				 */
				
				try {
				    List items = upload.parseRequest(request);
				    InputStream is = null;
				    Iterator iter = items.iterator();
				    while(iter.hasNext()) {
				        FileItem item = (FileItem)iter.next();
				        // �жϸ������Ƿ���file����
				        if (!item.isFormField()) {
				        	//��ȡ�ļ���
							fileName = item.getName();
							//�洢·��
							/*String path =request.getRealPath("/img/"+fileName);*/
							File uploadedFile = new File("D://Tomcat/apache-tomcat-9.0.0.M26-windows-x64/apache-tomcat-9.0.0.M26/webapps/lzxp/img/"+fileName);//�浽ǰ̨
							
							//д����
							item.write(uploadedFile);
				         } else {
				            // ����file���͵Ļ���������getFieldName�ж�name���Ի�ȡ��Ӧ��ֵ
				        	 String name = item.getFieldName();
				        	 String value = item.getString("utf-8");
				             if("goodsName".equals(name)) {
				                 goodsName = value;
				          }else if (name.equals("stype")) {
							//С����
							stypeName = value;
							if ("default".equals(stypeName)) {
								stypeName = null;
									}
				          }else if (name.equals("goodsPrice")) {
									//�۸�
									
									if (!"".equals(value)) {
										//����۸�Ϊ��ֵ
										goodsPrice= Double.parseDouble(value);
									}
				          }else if (name.equals("goodsContent")) {
									//����
									goodsContent = value;
						  }else{
									//���
									if (!"".equals(name)) {
										//�����治Ϊ��ֵ
										goodsStock = Integer.parseInt(value);
									}
								}
				         }
				    }
				} catch(Exception e) {
				    e.printStackTrace();
				}
				
			   
				//������Ʒ����
				Goods goods = new Goods(0, goodsName, 0, goodsPrice, goodsContent, goodsStock, 0);
				
				// ����service��add����
				boolean updateSucess = gs.addGoods(goods, stypeName,"img/"+fileName);
				//��ȡ������Ʒ
				list = gs.getAllGoods();
				//���ò����������
				request.setAttribute("updateSucess", updateSucess);
		        
			}  else if (op.equals("deleteGoods")) {
				// ɾ������
				String goodsIdStr = request.getParameter("goodsIdStr");
				
				String[] goodsId=goodsIdStr.split(",");
				
				for(int i=0;i<goodsId.length;i++){
					
					boolean updateSucess = gs.deleteGoods(Integer.parseInt(goodsId[i]));
					
					request.setAttribute("updateSucess", updateSucess);
				}
			
				list = gs.getAllGoods();

			
			
			}else if (op.equals("updateGoods")) {

				/**
				 * �޸���Ʒ
				 */
				
				int goodsId = 0;
				String goodsStype = "�������";
				try {
				    List items = upload.parseRequest(request);
				    InputStream is = null;
				    Iterator iter = items.iterator();
				    while(iter.hasNext()) {
				        FileItem item = (FileItem)iter.next();
				        // �жϸ������Ƿ���file����
				        if (!item.isFormField()) {
				        	//��ȡ�ļ���
							fileName = item.getName();
							//�洢·��
							File uploadedFile = new File("D://Tomcat/apache-tomcat-9.0.0.M26-windows-x64/apache-tomcat-9.0.0.M26/webapps/lzxp/img/"+fileName);//�浽ǰ̨
							
							//д����
							item.write(uploadedFile);
				         } else {
				            // ����file���͵Ļ���������getFieldName�ж�name���Ի�ȡ��Ӧ��ֵ
				        	 String name = item.getFieldName();
				        	 String value = item.getString("utf-8");
				             
				        	 if ("goodsId".equals(name)) {
								//��ƷID
				        		 goodsId = Integer.parseInt(value);
							}else if("goodsName".equals(name)) {
								//��Ʒ��
				                 goodsName = value;  
							}else if("goodsStype".equals(name)){
				        	  //��ƷС����
				        	  if (!"default".equals(value)) {
									//�����ƷС�಻Ϊ��
									goodsStype = value;
								}
							}else if (name.equals("stype")) {
							//��ƷС����
							stypeName = value;
							if ("default".equals(stypeName)) {
								stypeName = null;
									}
							}else if (name.equals("goodsPrice")) {
									//�۸�
									
									if (!"".equals(value)) {
										//����۸�Ϊ��ֵ
										goodsPrice= Double.parseDouble(value);
									}
							}else if (name.equals("goodsContent")) {
									//����
									goodsContent = value;
							}else{
									//���
									if (!"".equals(name)) {
										//�����治Ϊ��ֵ
										goodsStock = Integer.parseInt(value);
									}
								}
				         }
				    }
				} catch(Exception e) {
				    e.printStackTrace();
				}
				
				
				Goods goods=new Goods(goodsId,goodsName, 0,goodsPrice,goodsContent,goodsStock,0);
				//�޸���Ʒ
				boolean updateSucess =gs.updateGoods(goods, goodsStype,"img/"+fileName);
				//�޸���Ʒ��ַ
				
				list = gs.getAllGoods();
				request.setAttribute("updateSucess", updateSucess);
			
			}
		}

		// ��������ظ�goods-list.jsp
		
		//��ȡ��Ʒ��С��
		List<Goods_stype> stypeList = gs.getStype();
		
		//������ƷС�����
		request.setAttribute("stypeList", stypeList);
		// ������Ҫ���ݵ�����
		request.setAttribute("list", list);

		// ��ת��
		request.getRequestDispatcher("goods-list.jsp").forward(request, response);
	
	}

}