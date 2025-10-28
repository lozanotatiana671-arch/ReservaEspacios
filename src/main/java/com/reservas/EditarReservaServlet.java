package com.reservas;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

@WebServlet("/EditarReservaServlet")
public class EditarReservaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");

        try (Connection con = ConexionDB.getConnection()) {
            String sql = "SELECT id, nombre, TO_CHAR(fecha, 'YYYY-MM-DD'), hora FROM reservas WHERE id = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(id));
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                request.setAttribute("id", rs.getInt(1));
                request.setAttribute("nombre", rs.getString(2));
                request.setAttribute("fecha", rs.getString(3));
                request.setAttribute("hora", rs.getString(4));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.getRequestDispatcher("editarReserva.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");
        String nombre = request.getParameter("nombre");
        String fecha = request.getParameter("fecha");
        String hora = request.getParameter("hora");

        try (Connection con = ConexionDB.getConnection()) {
            String sql = "UPDATE reservas SET nombre = ?, fecha = TO_DATE(?, 'YYYY-MM-DD'), hora = ? WHERE id = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, nombre);
            ps.setString(2, fecha);
            ps.setString(3, hora);
            ps.setInt(4, Integer.parseInt(id));
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("ListaReservasServlet");
    }
}
