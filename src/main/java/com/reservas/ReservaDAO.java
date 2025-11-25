package com.reservas;

import java.sql.*;
import java.util.*;

public class ReservaDAO {

    // 🔹 Listar reservas
    public List<Reserva> listar() {
        List<Reserva> lista = new ArrayList<>();
        String sql = "SELECT id, nombre, TO_CHAR(fecha, 'YYYY-MM-DD') AS fecha, " +
                     "hora_inicio, hora_fin, estado, usuario_id, recurso_id " +
                     "FROM reservas";

        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Reserva r = new Reserva();
                r.setId(rs.getInt("id"));
                r.setNombre(rs.getString("nombre"));
                r.setFecha(rs.getString("fecha"));
                r.setHoraInicio(rs.getString("hora_inicio"));
                r.setHoraFin(rs.getString("hora_fin"));
                r.setEstado(rs.getString("estado"));
                r.setUsuarioId(rs.getInt("usuario_id"));
                r.setRecursoId(rs.getInt("recurso_id"));
                lista.add(r);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return lista;
    }

    // 🔹 Guardar nueva reserva con rango
    public boolean guardarConRango(Reserva r) {
        String sql = "INSERT INTO reservas (nombre, fecha, hora_inicio, hora_fin, estado, usuario_id, recurso_id) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, r.getNombre());
            ps.setDate(2, java.sql.Date.valueOf(r.getFecha()));
            ps.setString(3, r.getHoraInicio());
            ps.setString(4, r.getHoraFin());
            ps.setString(5, r.getEstado());
            ps.setInt(6, r.getUsuarioId());
            ps.setInt(7, r.getRecursoId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();  // 👈 imprime la causa real en consola
            throw new RuntimeException("Error SQL: " + e.getMessage(), e);
        }
    }

    // 🔹 Verificar conflicto de horario (ARREGLADO para que sí detecte choques)
    public boolean hayConflicto(int recursoId, java.sql.Date fecha, String horaInicio, String horaFin) {
        String sql = "SELECT hora_inicio, hora_fin FROM reservas " +
                     "WHERE recurso_id = ? " +
                     "AND fecha = ? " +  // ✅ compatible con DATE en PostgreSQL
                     "AND UPPER(estado) IN ('PENDIENTE', 'APROBADA', 'PRESTADO')";

        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, recursoId);
            ps.setDate(2, fecha);

            try (ResultSet rs = ps.executeQuery()) {
                int inicioNueva = convertirAHorasMinutos(horaInicio);
                int finNueva = convertirAHorasMinutos(horaFin);

                while (rs.next()) {
                    int inicioExistente = convertirAHorasMinutos(rs.getString("hora_inicio"));
                    int finExistente = convertirAHorasMinutos(rs.getString("hora_fin"));

                    // ✅ Hay conflicto si los rangos SE SOLAPAN
                    if (!(finNueva <= inicioExistente || inicioNueva >= finExistente)) {
                        return true;
                    }
                }
            }

        } catch (SQLException e) {
            System.err.println("⚠️ Error en hayConflicto(): " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    private int convertirAHorasMinutos(String hora) {
        String[] partes = hora.split(":");
        int h = Integer.parseInt(partes[0]);
        int m = Integer.parseInt(partes[1]);
        return h * 60 + m;
    }

    // 🔹 Cambiar estado de una reserva por ID ✅
    public void cambiarEstado(int id, String nuevoEstado) {
        String sql = "UPDATE reservas SET estado = ? WHERE id = ?";
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, nuevoEstado);
            ps.setInt(2, id);
            ps.executeUpdate();

            System.out.println("✅ Estado de la reserva " + id + " cambiado a: " + nuevoEstado);
        } catch (SQLException e) {
            System.err.println("❌ Error al cambiar estado de la reserva: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
