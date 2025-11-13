package com.reservas;

import java.sql.*;
import java.util.*;

public class ConsultaDAO {

    // 🔹 Registrar consulta (contacto)
    public boolean registrar(Consulta c) {

        String sql = "INSERT INTO contactos (usuario_id, nombre, correo, mensaje) " +
                     "VALUES (?, ?, ?, ?)";

        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, c.getUsuarioId());
            ps.setString(2, c.getNombre());
            ps.setString(3, c.getCorreo());
            ps.setString(4, c.getMensaje());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 🔹 Listar consultas para el admin
    public List<Consulta> listar() {
        List<Consulta> lista = new ArrayList<>();

        String sql = "SELECT id, usuario_id, nombre, correo, mensaje, fecha " +
                     "FROM contactos ORDER BY fecha DESC";

        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Consulta c = new Consulta();

                c.setId(rs.getInt("id"));
                c.setUsuarioId(rs.getInt("usuario_id"));
                c.setNombre(rs.getString("nombre"));
                c.setCorreo(rs.getString("correo"));
                c.setMensaje(rs.getString("mensaje"));
                c.setFecha(rs.getString("fecha"));

                lista.add(c);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return lista;
    }
}
