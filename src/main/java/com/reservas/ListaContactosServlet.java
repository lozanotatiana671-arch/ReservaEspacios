package com.reservas;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

@WebServlet("/ListaContactosServlet")
public class ListaContactosServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Map<String, String>> contactos = new ArrayList<>();

        try (Connection con = ConexionDB.getConnection()) {
            String sql = "SELECT id, nombre, correo, mensaje, TO_CHAR(fecha, 'YYYY-MM-DD HH24:MI') AS fecha FROM contactos ORDER BY fecha DESC";
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, String> fila = new HashMap<>();
                fila.put("id", String.valueOf(rs.getInt("id")));
                fila.put("nombre", rs.getString("nombre"));
                fila.put("correo", rs.getString("correo"));
                fila.put("mensaje", rs.getString("mensaje"));
                fila.put("fecha", rs.getString("fecha"));
                contactos.add(fila);
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error al consultar los contactos", e);
        }

        request.setAttribute("contactos", contactos);
        request.getRequestDispatcher("listaContactos.jsp").forward(request, response);
    }
}
