package com.reservas;

import java.sql.*;
import java.util.*;

public class BannerDAO {

   // 🔹 Registrar nuevo banner
public boolean registrar(Banner b) {
    // 👇 el ID  Oracle lo genera automáticamente
    String sql = "INSERT INTO banners (titulo, imagen, activo) VALUES (?, ?, ?)";

    try (Connection con = ConexionDB.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setString(1, b.getTitulo());
        ps.setString(2, b.getImagen());
        ps.setString(3, b.isActivo() ? "S" : "N");

        return ps.executeUpdate() > 0;
    } catch (Exception e) {
        System.out.println("❌ Error al registrar banner: " + e.getMessage());
        e.printStackTrace();
        return false;
    }
}


    // 🔹 Actualizar banner existente
    public boolean actualizar(Banner b) {
        String sql = "UPDATE banners SET titulo=?, imagen=?, activo=? WHERE id=?";
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, b.getTitulo());
            ps.setString(2, b.getImagen());
            ps.setString(3, b.isActivo() ? "S" : "N");
            ps.setInt(4, b.getId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 🔹 Listar todos los banners
    public List<Banner> listar() {
        List<Banner> lista = new ArrayList<>();
        String sql = "SELECT * FROM banners ORDER BY id DESC";

        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Banner b = new Banner();
                b.setId(rs.getInt("id"));
                b.setTitulo(rs.getString("titulo"));
                b.setImagen(rs.getString("imagen"));
                b.setActivo("S".equals(rs.getString("activo")));
                lista.add(b);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return lista;
    }

    // 🔹 Buscar banner por id
    public Banner buscarPorId(int id) {
        String sql = "SELECT * FROM banners WHERE id=?";
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Banner b = new Banner();
                b.setId(rs.getInt("id"));
                b.setTitulo(rs.getString("titulo"));
                b.setImagen(rs.getString("imagen"));
                b.setActivo("S".equals(rs.getString("activo")));
                return b;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // 🔹 Eliminar banner
    public boolean eliminar(int id) {
        String sql = "DELETE FROM banners WHERE id=?";
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
