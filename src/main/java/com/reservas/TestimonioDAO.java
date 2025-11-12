package com.reservas;

import java.sql.*;
import java.util.*;

public class TestimonioDAO {

    // 🔹 Registrar testimonio simple
    public boolean registrar(Testimonio t) {
        String sql = "INSERT INTO testimonios (usuario_id, mensaje, estado, fecha) " +
                     "VALUES (?, ?, 'Pendiente', CURRENT_TIMESTAMP)";
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, t.getUsuarioId());
            ps.setString(2, t.getMensaje());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("❌ Error al registrar testimonio: " + e.getMessage());
            return false;
        }
    }

    // 🔹 Registrar testimonio con calificación y recurso
    public boolean registrarConCalificacion(Testimonio t) {
        String sql = "INSERT INTO testimonios (usuario_id, recurso_id, mensaje, calificacion, estado, fecha) " +
                     "VALUES (?, ?, ?, ?, 'Pendiente', CURRENT_TIMESTAMP)";
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            System.out.println("🟢 Insertando testimonio -> usuario=" + t.getUsuarioId() +
                               ", recurso=" + t.getRecursoId() +
                               ", calificación=" + t.getCalificacion() +
                               ", mensaje=" + t.getMensaje());

            ps.setInt(1, t.getUsuarioId());
            ps.setInt(2, t.getRecursoId());
            ps.setString(3, t.getMensaje());
            ps.setInt(4, t.getCalificacion());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("❌ Error al registrar testimonio con calificación: " + e.getMessage());
            return false;
        }
    }

    // 🔹 Listar todos los testimonios
    public List<Testimonio> listar() {
        List<Testimonio> lista = new ArrayList<>();
        String sql = "SELECT t.id, t.usuario_id, u.nombre, t.mensaje, t.estado, " +
                     "TO_CHAR(t.fecha, 'YYYY-MM-DD HH24:MI') AS fecha " +
                     "FROM testimonios t JOIN usuarios u ON t.usuario_id = u.id " +
                     "ORDER BY t.fecha DESC";
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Testimonio t = new Testimonio();
                t.setId(rs.getInt("id"));
                t.setUsuarioId(rs.getInt("usuario_id"));
                t.setUsuarioNombre(rs.getString("nombre"));
                t.setMensaje(rs.getString("mensaje"));
                t.setEstado(rs.getString("estado"));
                t.setFecha(rs.getString("fecha"));
                lista.add(t);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return lista;
    }

    // 🔹 Cambiar estado (Aprobado / Pendiente)
    public boolean cambiarEstado(int id, String estado) {
        String sql = "UPDATE testimonios SET estado = ? WHERE id = ?";
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, estado);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 🔹 Eliminar testimonio
    public boolean eliminar(int id) {
        String sql = "DELETE FROM testimonios WHERE id = ?";
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 🔹 Listar aprobados
    public List<Testimonio> listarAprobados() {
        List<Testimonio> lista = new ArrayList<>();
        String sql = "SELECT t.id, t.usuario_id, u.nombre AS usuarioNombre, " +
                     "t.mensaje, t.calificacion, t.fecha " +
                     "FROM testimonios t JOIN usuarios u ON t.usuario_id = u.id " +
                     "WHERE t.estado = 'Aprobado' ORDER BY t.fecha DESC";
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Testimonio t = new Testimonio();
                t.setId(rs.getInt("id"));
                t.setUsuarioId(rs.getInt("usuario_id"));
                t.setUsuarioNombre(rs.getString("usuarioNombre"));
                t.setMensaje(rs.getString("mensaje"));
                t.setCalificacion(rs.getInt("calificacion"));
                t.setFecha(rs.getString("fecha"));
                lista.add(t);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return lista;
    }

    // 🔹 Listar por usuario
    public List<Testimonio> listarPorUsuario(int usuarioId) {
        List<Testimonio> lista = new ArrayList<>();
        String sql = "SELECT t.id, t.mensaje, t.estado, " +
                     "TO_CHAR(t.fecha, 'YYYY-MM-DD HH24:MI') AS fecha, " +
                     "r.nombre AS recursoNombre " +
                     "FROM testimonios t " +
                     "LEFT JOIN recursos r ON t.recurso_id = r.id " +
                     "WHERE t.usuario_id = ? ORDER BY t.fecha DESC";
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, usuarioId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Testimonio t = new Testimonio();
                t.setId(rs.getInt("id"));
                t.setMensaje(rs.getString("mensaje"));
                t.setEstado(rs.getString("estado"));
                t.setFecha(rs.getString("fecha"));
                String nombreRecurso = rs.getString("recursoNombre");
