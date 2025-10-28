package com.reservas;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

@WebServlet("/ListaReservasServlet")
public class ListaReservasServlet extends HttpServlet {

    private static final int PAGE_SIZE = 6;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Reserva> reservas = new ArrayList<>();
        int totalReservas = 0;
        int totalEspacios = 0;
        int totalTestimonios = 0;
        int totalClientes = 0;

        int page = 1;
        try {
            if (request.getParameter("page") != null) {
                page = Integer.parseInt(request.getParameter("page"));
            }
        } catch (NumberFormatException e) {
            page = 1;
        }
        int offset = (page - 1) * PAGE_SIZE;

        String usuario = request.getParameter("usuario");
        String recurso = request.getParameter("recurso");
        String estado = request.getParameter("estado");

        List<Object> params = new ArrayList<>();
        String where = "WHERE 1=1 ";

        if (usuario != null && !usuario.isEmpty()) {
            where += "AND LOWER(r.nombre) LIKE ? ";
            params.add("%" + usuario.toLowerCase() + "%");
        }
        if (recurso != null && !recurso.isEmpty()) {
            where += "AND LOWER(rc.nombre) LIKE ? ";
            params.add("%" + recurso.toLowerCase() + "%");
        }
        if (estado != null && !estado.isEmpty()) {
            where += "AND r.estado = ? ";
            params.add(estado);
        }

        try (Connection con = ConexionDB.getConnection()) {

            // 🔹 Listar reservas (ahora con hora_inicio y hora_fin)
            String sql = "SELECT r.id, r.nombre, TO_CHAR(r.fecha, 'YYYY-MM-DD') AS fecha, " +
                         "r.hora_inicio, r.hora_fin, r.estado, rc.nombre AS recurso_nombre " +
                         "FROM reservas r " +
                         "JOIN recursos rc ON r.recurso_id = rc.id " +
                         where +
                         "ORDER BY r.fecha DESC, r.hora_inicio DESC " +
                         "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

            PreparedStatement ps = con.prepareStatement(sql);

            int idx = 1;
            for (Object p : params) {
                ps.setObject(idx++, p);
            }
            ps.setInt(idx++, offset);
            ps.setInt(idx, PAGE_SIZE);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Reserva r = new Reserva();
                r.setId(rs.getInt("id"));
                r.setNombre(rs.getString("nombre"));
                r.setFecha(rs.getString("fecha"));
                r.setHoraInicio(rs.getString("hora_inicio"));
                r.setHoraFin(rs.getString("hora_fin"));
                r.setEstado(rs.getString("estado"));
                r.setRecursoNombre(rs.getString("recurso_nombre"));
                reservas.add(r);
            }

            // 🔹 Contar reservas totales
            String sqlCount = "SELECT COUNT(*) AS total FROM reservas r " +
                              "JOIN recursos rc ON r.recurso_id = rc.id " + where;
            PreparedStatement psCount = con.prepareStatement(sqlCount);
            idx = 1;
            for (Object p : params) {
                psCount.setObject(idx++, p);
            }
            ResultSet rsCount = psCount.executeQuery();
            if (rsCount.next()) {
                totalReservas = rsCount.getInt("total");
            }

            // 🔹 Contar espacios
            PreparedStatement psEspacios = con.prepareStatement("SELECT COUNT(*) FROM recursos");
            ResultSet rsEspacios = psEspacios.executeQuery();
            if (rsEspacios.next()) {
                totalEspacios = rsEspacios.getInt(1);
            }

            // 🔹 Contar testimonios
            PreparedStatement psTestimonios = con.prepareStatement("SELECT COUNT(*) FROM testimonios");
            ResultSet rsTestimonios = psTestimonios.executeQuery();
            if (rsTestimonios.next()) {
                totalTestimonios = rsTestimonios.getInt(1);
            }

            // 🔹 Contar clientes (excluyendo admin)
            PreparedStatement psClientes = con.prepareStatement("SELECT COUNT(*) FROM usuarios WHERE rol <> 'admin'");
            ResultSet rsClientes = psClientes.executeQuery();
            if (rsClientes.next()) {
                totalClientes = rsClientes.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error al listar reservas", e);
        }

        int totalPages = (int) Math.ceil((double) totalReservas / PAGE_SIZE);

        // 🔹 Mandar datos al JSP
        request.setAttribute("reservas", reservas);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalReservas", totalReservas);
        request.setAttribute("totalEspacios", totalEspacios);
        request.setAttribute("totalTestimonios", totalTestimonios);
        request.setAttribute("totalClientes", totalClientes);

        request.getRequestDispatcher("listadoReservas.jsp").forward(request, response);
    }
    @Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    // 🔹 Redirige internamente a doGet, manteniendo los filtros del formulario
    doGet(request, response);
}

}
