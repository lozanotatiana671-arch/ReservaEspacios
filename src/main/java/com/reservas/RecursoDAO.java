package com.reservas;

import java.sql.*;
import java.util.*;

public class RecursoDAO {

    // 🔹 Listar todos los recursos
    public static List<Recurso> listar() throws SQLException {
        List<Recurso> lista = new ArrayList<>();
        String sql = "SELECT * FROM recursos ORDER BY id";

        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Recurso r = new Recurso();
                r.setId(rs.getInt("id"));
                r.setNombre(rs.getString("nombre"));
                r.setDescripcion(rs.getString("descripcion"));
                r.setTipo(rs.getString("tipo"));
                r.setEstado(rs.getString("estado"));
                r.setTarifa(rs.getDouble("tarifa"));
                r.setImagen(rs.getString("imagen"));

                // Campos opcionales
                try { r.setUbicacion(rs.getString("ubicacion")); } catch (SQLException e) {}
                try { r.setCapacidad(rs.getInt("capacidad")); } catch (SQLException e) {}

                // Estado disponible
                r.setDisponible("DISPONIBLE".equalsIgnoreCase(r.getEstado()));

                lista.add(r);
            }
        }

        // 🔹 Cargar promedios y total de reseñas
        agregarValoracionesARecursos(lista);

        return lista;
    }

    // 🔹 Insertar nuevo recurso
    public static void insertar(Recurso r) throws SQLException {
        String sql = "INSERT INTO recursos (nombre, descripcion, tipo, estado, tarifa, imagen, ubicacion, capacidad) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, r.getNombre());
            ps.setString(2, r.getDescripcion());
            ps.setString(3, r.getTipo());
            ps.setString(4, r.getEstado());
            ps.setDouble(5, r.getTarifa());
            ps.setString(6, r.getImagen());
            ps.setString(7, r.getUbicacion());
            ps.setInt(8, r.getCapacidad());

            ps.executeUpdate();
        }
    }

    // 🔹 Actualizar recurso
    public static void actualizar(Recurso r) throws SQLException {
        String sql = "UPDATE recursos SET nombre=?, descripcion=?, tipo=?, estado=?, tarifa=?, imagen=?, ubicacion=?, capacidad=? WHERE id=?";

        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, r.getNombre());
            ps.setString(2, r.getDescripcion());
            ps.setString(3, r.getTipo());
            ps.setString(4, r.getEstado());
            ps.setDouble(5, r.getTarifa());
            ps.setString(6, r.getImagen());
            ps.setString(7, r.getUbicacion());
            ps.setInt(8, r.getCapacidad());
            ps.setInt(9, r.getId());

            ps.executeUpdate();
        }
    }

    // 🔹 Eliminar recurso
    public static void eliminar(int id) throws SQLException {
        String sql = "DELETE FROM recursos WHERE id=?";

        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    // 🔹 Listar recursos disponibles en fecha y hora
    public static List<Recurso> listarDisponibles(String fecha, String hora) throws SQLException {
        List<Recurso> lista = new ArrayList<>();

        String sql =
            "SELECT r.id, r.nombre, r.descripcion, r.tipo, r.estado, r.tarifa, r.imagen, r.ubicacion, r.capacidad " +
            "FROM recursos r WHERE r.estado = 'ACTIVO'";

        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Recurso r = new Recurso();
                r.setId(rs.getInt("id"));
                r.setNombre(rs.getString("nombre"));
                r.setDescripcion(rs.getString("descripcion"));
                r.setTipo(rs.getString("tipo"));
                r.setEstado(rs.getString("estado"));
                r.setTarifa(rs.getDouble("tarifa"));
                r.setImagen(rs.getString("imagen"));
                r.setUbicacion(rs.getString("ubicacion"));
                r.setCapacidad(rs.getInt("capacidad"));
                r.setDisponible(true);

                lista.add(r);
            }
        }

        return lista;
    }

    // ==========================================================
    // ⭐ NUEVO: Cargar promedios reales de los testimonios
    // ==========================================================
    private static void agregarValoracionesARecursos(List<Recurso> recursos) {
        if (recursos == null || recursos.isEmpty()) return;

        String sql =
            "SELECT recurso_id, AVG(calificacion) AS promedio, COUNT(*) AS total " +
            "FROM testimonios WHERE estado = 'Aprobado' GROUP BY recurso_id";

        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            Map<Integer, double[]> mapa = new HashMap<>();

            while (rs.next()) {
                int idRecurso = rs.getInt("recurso_id");   // ✔ NOMBRE CORRECTO
                double promedio = rs.getDouble("promedio");
                int total = rs.getInt("total");

                mapa.put(idRecurso, new double[]{promedio, total});
            }

            // 🔹 Inyectar valores en cada recurso
            for (Recurso r : recursos) {
                if (mapa.containsKey(r.getId())) {
                    double[] v = mapa.get(r.getId());
                    r.setPromedioValoracion(v[0]);
                    r.setTotalResenas((int) v[1]);
                } else {
                    r.setPromedioValoracion(0.0);
                    r.setTotalResenas(0);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("⚠️ Error al calcular promedios: " + e.getMessage());
        }
    }
}
