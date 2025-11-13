package com.reservas;

import java.sql.*;
import java.util.*;

public class NotificacionDAO {

    public List<Notificacion> listarPorUsuario(int usuarioId) {
        List<Notificacion> lista = new ArrayList<>();
        String sql = "SELECT id, reserva_id, usuario_id, mensaje, estado, fecha " +
                     "FROM notificaciones WHERE usuario_id = ? ORDER BY fecha DESC";

        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, usuarioId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notificacion n = new Notificacion();
                    n.setId(rs.getInt("id"));

                    int rid = rs.getInt("reserva_id");
                    if (rs.wasNull()) n.setReservaId(null);
                    else n.setReservaId(rid);

                    n.setUsuarioId(rs.getInt("usuario_id"));
                    n.setMensaje(rs.getString("mensaje"));
                    n.setEstado(rs.getString("estado"));
                    n.setFecha(rs.getTimestamp("fecha"));

                    lista.add(n);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return lista;
    }

    public void insertar(Notificacion n) {
        String sql = "INSERT INTO notificaciones (reserva_id, usuario_id, mensaje, estado, fecha) " +
                     "VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)";

        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            if (n.getReservaId() == null) {
                ps.setNull(1, Types.INTEGER);
            } else {
                ps.setInt(1, n.getReservaId());
            }

            ps.setInt(2, n.getUsuarioId());
            ps.setString(3, n.getMensaje());
            ps.setString(4, n.getEstado() != null ? n.getEstado() : "NUEVA");

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void marcarLeida(int id) {
        String sql = "UPDATE notificaciones SET estado = 'LEIDA' WHERE id = ?";
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void marcarTodasLeidas(int usuarioId) {
        String sql = "UPDATE notificaciones SET estado = 'LEIDA' " +
                     "WHERE usuario_id = ? AND estado = 'NUEVA'";

        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, usuarioId);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public int contarNoLeidas(int usuarioId) {
        String sql = "SELECT COUNT(*) FROM notificaciones " +
                     "WHERE usuario_id = ? AND estado = 'NUEVA'";

        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, usuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }
}
