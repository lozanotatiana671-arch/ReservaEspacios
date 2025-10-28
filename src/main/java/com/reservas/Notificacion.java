package com.reservas;

import java.sql.Timestamp;

public class Notificacion {
    private int id;
    private Integer reservaId;
    private int usuarioId;
    private String mensaje;
    private String estado; // 'NUEVA' o 'LEIDA'
    private Timestamp fecha;

    // Getters / Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Integer getReservaId() { return reservaId; }
    public void setReservaId(Integer reservaId) { this.reservaId = reservaId; }

    public int getUsuarioId() { return usuarioId; }
    public void setUsuarioId(int usuarioId) { this.usuarioId = usuarioId; }

    public String getMensaje() { return mensaje; }
    public void setMensaje(String mensaje) { this.mensaje = mensaje; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public Timestamp getFecha() { return fecha; }
    public void setFecha(Timestamp fecha) { this.fecha = fecha; }
}
