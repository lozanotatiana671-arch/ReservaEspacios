package com.reservas;

import java.sql.*;
import java.util.*;

public class NotificacionDAO {

    public List<Notificacion> listarPorUsuario(int usuarioId) {
        List<Notificacion> lista = new ArrayList<>();
        String sql = "SELECT ID, RESERVA_ID, USUARIO_ID, MENSAJE, ESTADO, FECHA " +
                     "FROM NOTIFICACIONES WHERE USUARIO_ID = ? ORDER BY FECHA DESC";
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notificacion n = new Notificacion();
                    n.setId(rs.getInt("ID"));
                    int rid = rs.getInt("RESERVA_ID");
                    if (rs.wasNull()) n.setReservaId(null); else n.setReservaId(rid);
                    n.setUsuarioId(rs.getInt("USUARIO_ID"));
                    n.setMensaje(rs.getString("MENSAJE"));
                    n.setEstado(rs.getString("ESTADO"));
                    n.setFecha(rs.getTimestamp("FECHA"));
                    lista.add(n);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return lista;
    }

    public void insertar(Notificacion n) {
        String sql = "INSERT INTO NOTIFICACIONES (RESERVA_ID, USUARIO_ID, MENSAJE, ESTADO, FECHA) " +
                     "VALUES (?, ?, ?, ?, SYSTIMESTAMP)";
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (n.getReservaId() == null) ps.setNull(1, Types.INTEGER); else ps.setInt(1, n.getReservaId());
            ps.setInt(2, n.getUsuarioId());
            ps.setString(3, n.getMensaje());
            ps.setString(4, n.getEstado() != null ? n.getEstado() : "NUEVA");
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void marcarLeida(int id) {
        String sql = "UPDATE NOTIFICACIONES SET ESTADO = 'LEIDA' WHERE ID = ?";
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void marcarTodasLeidas(int usuarioId) {
        String sql = "UPDATE NOTIFICACIONES SET ESTADO = 'LEIDA' WHERE USUARIO_ID = ? AND ESTADO = 'NUEVA'";
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public int contarNoLeidas(int usuarioId) {
        String sql = "SELECT COUNT(*) FROM NOTIFICACIONES WHERE USUARIO_ID = ? AND ESTADO = 'NUEVA'";
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
