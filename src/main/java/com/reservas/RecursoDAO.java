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

                // 🟢 Campos adicionales usados en el JSP (si existen en la tabla)
                try { r.setUbicacion(rs.getString("ubicacion")); } catch (SQLException e) {}
                try { r.setCapacidad(rs.getInt("capacidad")); } catch (SQLException e) {}
                try { r.setPromedioValoracion(rs.getDouble("promedio_valoracion")); } catch (SQLException e) {}
                try { r.setTotalResenas(rs.getInt("total_resenas")); } catch (SQLException e) {}

                // Marcamos disponible según el estado
                r.setDisponible("DISPONIBLE".equalsIgnoreCase(r.getEstado()));


                lista.add(r);
            }
        }

        // 🔹 Integrar automáticamente promedios de calificación
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

    // 🔹 Actualizar recurso existente
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

    // 🔹 Eliminar recurso por ID
    public static void eliminar(int id) throws SQLException {
        String sql = "DELETE FROM recursos WHERE id=?";
        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    // 🔹 Listar recursos disponibles según fecha y hora
    public static List<Recurso> listarDisponibles(String fecha, String hora) throws SQLException {
        List<Recurso> lista = new ArrayList<>();

        String sql = "SELECT r.id, r.nombre, r.descripcion, r.tipo, r.estado, r.tarifa, r.imagen, r.ubicacion, r.capacidad, " +
                     "       (SELECT CASE " +
                     "                 WHEN rs.estado = 'PRESTADO' " +
                     "                 THEN TO_CHAR(TO_DATE(rs.hora, 'HH24:MI') + INTERVAL '2' HOUR, 'HH24:MI') " +
                     "               END " +
                     "        FROM reservas rs " +
                     "        WHERE rs.recurso_id = r.id " +
                     "          AND rs.fecha = TO_DATE(?, 'YYYY-MM-DD') " +
                     "          AND rs.estado = 'PRESTADO' " +
                     "          AND TO_DATE(rs.hora, 'HH24:MI') <= TO_DATE(?, 'HH24:MI') " +
                     "          AND TO_DATE(rs.hora, 'HH24:MI') + INTERVAL '2' HOUR > TO_DATE(?, 'HH24:MI') " +
                     "        FETCH FIRST 1 ROWS ONLY) AS bloqueado_hasta " +
                     "FROM recursos r " +
                     "WHERE r.estado = 'ACTIVO' " +
                     "  AND NOT EXISTS ( " +
                     "        SELECT 1 FROM reservas rs2 " +
                     "        WHERE rs2.recurso_id = r.id " +
                     "          AND rs2.fecha = TO_DATE(?, 'YYYY-MM-DD') " +
                     "          AND rs2.estado IN ('APROBADA', 'PRESTADO') " +
                     "          AND rs2.hora = ? " +
                     "  )";

        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, fecha);
            ps.setString(2, hora);
            ps.setString(3, hora);
            ps.setString(4, fecha);
            ps.setString(5, hora);

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
                r.setDisponible(true); // ✅ disponible porque pasó los filtros

                String bloqueadoHasta = rs.getString("bloqueado_hasta");
                if (bloqueadoHasta != null) {
                    r.setMensajeBloqueo("⏳ Disponible a partir de las " + bloqueadoHasta);
                }

                lista.add(r);
            }
        }
        return lista;
    }

    // 🔹 Obtener fechas del mes actual con reservas activas
    public static Set<String> obtenerFechasConReservas() throws SQLException {
        Set<String> fechasOcupadas = new HashSet<>();

        String sql = "SELECT DISTINCT TO_CHAR(TRUNC(fecha), 'YYYY-MM-DD') AS fecha_reserva " +
                     "FROM reservas " +
                     "WHERE UPPER(estado) IN ('APROBADA', 'PRESTADO', 'PENDIENTE')";

        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                String fecha = rs.getString("fecha_reserva");
                if (fecha != null && !fecha.isBlank()) {
                    fechasOcupadas.add(fecha.trim());
                }
            }
        }

        System.out.println("🟢 Fechas ocupadas encontradas en BD: " + fechasOcupadas);
        return fechasOcupadas;
    }

    // ==========================================================
    // 🔸 NUEVO BLOQUE (sin alterar nada anterior)
    // ==========================================================

    /**
     * 🔹 Calcula los promedios y totales de calificaciones por recurso
     *    y los agrega a la lista ya obtenida en listar().
     *    Esto hace que en index.jsp se muestren las estrellas reales ⭐
     */
    private static void agregarValoracionesARecursos(List<Recurso> recursos) {
        if (recursos == null || recursos.isEmpty()) return;

        String sql = "SELECT id_recurso, AVG(calificacion) AS promedio, COUNT(*) AS total " +
                     "FROM testimonios WHERE estado = 'Aprobado' GROUP BY id_recurso";

        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            Map<Integer, double[]> mapa = new HashMap<>();
            while (rs.next()) {
                int idRecurso = rs.getInt("id_recurso");
                double promedio = rs.getDouble("promedio");
                int total = rs.getInt("total");
                mapa.put(idRecurso, new double[]{promedio, total});
            }

            // 🟢 Inyectar valores calculados
            for (Recurso r : recursos) {
                if (mapa.containsKey(r.getId())) {
                    double[] valores = mapa.get(r.getId());
                    r.setPromedioValoracion(valores[0]);
                    r.setTotalResenas((int) valores[1]);
                } else {
                    r.setPromedioValoracion(0.0);
                    r.setTotalResenas(0);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("⚠️ Error al calcular promedios de valoración: " + e.getMessage());
        }
    }
}
