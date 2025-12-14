package ar.edu.ubp.das.dto;

import java.time.LocalDateTime;

public class MenuDto {
    private Long nroMenu;
    private String nroRestaurante;
    private String nroSucursal;
    private String nombreArchivo;
    private String tipoMime;
    private Long tamanoBytes;
    private String hashSha256;
    private byte[] datosArchivo;
    private LocalDateTime fechaCreacion;
    private Boolean activo;

    // Getters y Setters
    public Long getNroMenu() { return nroMenu; }
    public void setNroMenu(Long nroMenu) { this.nroMenu = nroMenu; }

    public String getNroRestaurante() { return nroRestaurante; }
    public void setNroRestaurante(String nroRestaurante) { this.nroRestaurante = nroRestaurante; }

    public String getNroSucursal() { return nroSucursal; }
    public void setNroSucursal(String nroSucursal) { this.nroSucursal = nroSucursal; }

    public String getNombreArchivo() { return nombreArchivo; }
    public void setNombreArchivo(String nombreArchivo) { this.nombreArchivo = nombreArchivo; }

    public String getTipoMime() { return tipoMime; }
    public void setTipoMime(String tipoMime) { this.tipoMime = tipoMime; }

    public Long getTamanoBytes() { return tamanoBytes; }
    public void setTamanoBytes(Long tamanoBytes) { this.tamanoBytes = tamanoBytes; }

    public String getHashSha256() { return hashSha256; }
    public void setHashSha256(String hashSha256) { this.hashSha256 = hashSha256; }

    public byte[] getDatosArchivo() { return datosArchivo; }
    public void setDatosArchivo(byte[] datosArchivo) { this.datosArchivo = datosArchivo; }

    public LocalDateTime getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(LocalDateTime fechaCreacion) { this.fechaCreacion = fechaCreacion; }

    public Boolean getActivo() { return activo; }
    public void setActivo(Boolean activo) { this.activo = activo; }
}
