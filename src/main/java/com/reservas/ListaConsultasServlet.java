package com.reservas;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

@WebServlet("/ListaConsultasServlet")
public class ListaConsultasServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        ConsultaDAO dao = new ConsultaDAO();
        List<Consulta> consultas = dao.listar();

        request.setAttribute("consultas", consultas);
        request.getRequestDispatcher("consultas.jsp").forward(request, response);
    }
}
