package com.reservas;

import java.sql.*;
import java.util.*;

public class UsuarioDAO {

    // ✅ Registrar usuario
    public boolean registrar(Usuario u) {
        String sql = "INSERT INTO usuarios (nombre, identificacion, correo, telefono, password, rol) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, u.getNombre());
            ps.setString(2, u.getIdentificacion());
            ps.setString(3, u.getCorreo());
            ps.setString(4, u.getTelefono());
            ps.setString(5, u.getPassword());
            ps.setString(6, u.getRol());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ✅ Listar todos los usuarios
    public List<Usuario> listar() {
        List<Usuario> lista = new ArrayList<>();
        String sql = "SELECT * FROM usuarios ORDER BY id";
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Usuario u = new Usuario();
                u.setId(rs.getInt("id"));
                u.setNombre(rs.getString("nombre"));
                u.setIdentificacion(rs.getString("identificacion"));
                u.setCorreo(rs.getString("correo"));
                u.setTelefono(rs.getString("telefono"));
                u.setPassword(rs.getString("password")); // opcional, no se suele mostrar
                u.setRol(rs.getString("rol"));
                lista.add(u);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return lista;
    }

    // ✅ Buscar usuario por ID
    public Usuario obtenerPorId(int id) {
        String sql = "SELECT * FROM usuarios WHERE id = ?";
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Usuario u = new Usuario();
                    u.setId(rs.getInt("id"));
                    u.setNombre(rs.getString("nombre"));
                    u.setIdentificacion(rs.getString("identificacion"));
                    u.setCorreo(rs.getString("correo"));
                    u.setTelefono(rs.getString("telefono"));
                    u.setPassword(rs.getString("password"));
                    u.setRol(rs.getString("rol"));
                    return u;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // ✅ Buscar usuarios por nombre o identificación
public List<Usuario> buscar(String criterio) {
    List<Usuario> lista = new ArrayList<>();
    String sql = "SELECT * FROM usuarios WHERE LOWER(nombre) LIKE ? OR identificacion LIKE ? ORDER BY id";
    try (Connection con = ConexionDB.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setString(1, "%" + criterio.toLowerCase() + "%");
        ps.setString(2, "%" + criterio + "%");

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Usuario u = new Usuario();
                u.setId(rs.getInt("id"));
                u.setNombre(rs.getString("nombre"));
                u.setIdentificacion(rs.getString("identificacion"));
                u.setCorreo(rs.getString("correo"));
                u.setTelefono(rs.getString("telefono"));
                u.setRol(rs.getString("rol"));
                lista.add(u);
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return lista;
}


    // ✅ Actualizar usuario
    public boolean actualizar(Usuario u) {
        String sql = "UPDATE usuarios SET nombre=?, identificacion=?, correo=?, telefono=?, rol=? WHERE id=?";
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, u.getNombre());
            ps.setString(2, u.getIdentificacion());
            ps.setString(3, u.getCorreo());
            ps.setString(4, u.getTelefono());
            ps.setString(5, u.getRol());
            ps.setInt(6, u.getId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ✅ Eliminar usuario
    public boolean eliminar(int id) {
        String sql = "DELETE FROM usuarios WHERE id=?";
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
