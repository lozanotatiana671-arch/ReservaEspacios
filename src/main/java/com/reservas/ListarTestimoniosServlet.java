package com.reservas;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

@WebServlet("/ListarTestimoniosServlet")
public class ListarTestimoniosServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        TestimonioDAO dao = new TestimonioDAO();
        List<Testimonio> testimonios = dao.listar();

        request.setAttribute("testimonios", testimonios);
        request.getRequestDispatcher("testimonios.jsp").forward(request, response);
    }
}
