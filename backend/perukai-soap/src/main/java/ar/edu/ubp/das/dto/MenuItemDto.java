package ar.edu.ubp.das.dto;

public class MenuItemDto {
  private String nroMenu;
  private String nomMenu;
  private String nroPlato;
  private String nomPlato;

  public MenuItemDto() {
  }

  public MenuItemDto(String nroMenu, String nomMenu, String nroPlato, String nomPlato) {
    this.nroMenu = nroMenu;
    this.nomMenu = nomMenu;
    this.nroPlato = nroPlato;
    this.nomPlato = nomPlato;
  }

  public String getNroMenu() {
    return nroMenu;
  }

  public void setNroMenu(String nroMenu) {
    this.nroMenu = nroMenu;
  }
  
  public String getNomMenu() {
    return nomMenu;
  }

  public void setNomMenu(String nomMenu) {
    this.nomMenu = nomMenu;
  }
  
  public String getNroPlato() {
    return nroPlato;
  }

  public void setNroPlato(String nroPlato) {
    this.nroPlato = nroPlato;
  }

  public String getNomPlato() {
    return nomPlato;
  }

  public void setNomPlato(String nomPlato) {
    this.nomPlato = nomPlato;
  }
}
