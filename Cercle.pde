// import 3D camera handler package (PeasyCam)
import peasy.*;

// camera
PeasyCam cam;

// dimension de la fenetre
int dimX = 850;
int dimY = 850;


/////////////////////////////////////////////////////////////////////////
// VARIABLES DU CERCLE
/////////////////////////////////////////////////////////////////////////
// coordonnees du centre du cercle
PVector centre = new PVector (0, 0, 0);

// rayon du cercle
float radius = 50;

// epaisseur du cercle
float thickness = 2;

// couleur du cercle
color couleur = color(255,0,0);

// taille du voxel de representation de la sphere
int tailleVoxel = 5;

// sphere coupee pour voir l'epaisseur
boolean cut = true;





void settings () {
  // set the size of the windows
   size(dimX, dimY, P3D);
}



void draw() {
  background(51);
  
  ///////////////////////////////////////////////
  // Sélection de la méthode d'affichage
  ///////////////////////////////////////////////
  
  // Necessite d'avoir un radius minimum de 50 pour voir le cercle
  brut_force();
  
  //incrementale();
  
  //sphere();
}



void setup() {
  // init the camera 
  cam = new PeasyCam(this, 0, 0, 0, 700);
  cam.setMinimumDistance(50);        // distance minimale du zoom
  cam.setMaximumDistance(3000);      // distance maximale du zoom
}



/**
 * Calcul de l'équation du cercle pour un point 2D
 **/
float equat(int x, int y){
  return pow((x - centre.x),2)+pow((y - centre.y),2);
}



/**
 * Affichage des pixels pour chaque octant, correspondant au pixel passé en paramètre. dimX/2 et dimY/2 sont 
 * utilisés pour partir du principe que l'origine du repère se trouve au centre de l'écran.
 **/
void color_octant(PVector color_pixel){
  pixels[(int)(((color_pixel.y+dimY/2)*dimX)+color_pixel.x+dimX/2)]= couleur;
  pixels[(int)(((-color_pixel.y+dimY/2)*dimX)+color_pixel.x+dimX/2)]= couleur;
  pixels[(int)(((color_pixel.y+dimY/2)*dimX)-color_pixel.x+dimX/2)]= couleur;
  pixels[(int)(((-color_pixel.y+dimY/2)*dimX)-color_pixel.x+dimX/2)]= couleur;
  
  pixels[(int)(((color_pixel.x+dimY/2)*dimX)+color_pixel.y+dimX/2)]= couleur;
  pixels[(int)(((-color_pixel.x+dimY/2)*dimX)+color_pixel.y+dimX/2)]= couleur;
  pixels[(int)(((color_pixel.x+dimY/2)*dimX)-color_pixel.y+dimX/2)]= couleur;
  pixels[(int)(((-color_pixel.x+dimY/2)*dimX)-color_pixel.y+dimX/2)]= couleur;
}





/////////////////////////////////////////////////////////////////////////
// METHODES D'AFFICHAGE
/////////////////////////////////////////////////////////////////////////


/**
 * Affiche les pixels qui se trouve sur le périmètre du cercle (équation du cercle = 0), plus ou
 * moins l'épaiseur. L'algorithme utlise dimX/2 et dimY/2 dans les calcules pour partir du principe
 * que l'origine du repère se trouve au centre de l'écran.
 */
void brut_force(){
  // charger les pixels afficher à l'écran
  loadPixels();
  for ( int x = -dimX/2; x < dimX/2; x++ ) {
    for ( int y = -dimY/2; y < dimY/2; y++ ) {
      if ( pow(radius,2) <= equat(x,y) && equat(x,y) < pow(radius+thickness,2)){
        pixels[((y+dimX/2)*dimX)+x+dimY/2]= couleur;
      }
    }
  }
  // mettre à jour la nouvelle couleur des pixels sur l'écran
  updatePixels();
}


/**
 * Affiche le premier pixel d'un octant, pui calcul quel prochain pixel (à coté) doit être affiché.
 * Le prochain pixel à afficher est appliquer à chaque octant.
 */
void incrementale(){
  // charger les pixels afficher à l'écran
  loadPixels();
  
  // calcul et affichage du premier pixel
  PVector color_pixel = new PVector (centre.x + radius, centre.y);
  color_octant(color_pixel);
  
  // premier octant
  while (color_pixel.x>color_pixel.y){
    
    // si le pixel d'au-dessus appartient au périmètre
    if (pow(radius,2) <= equat((int)color_pixel.x, (int)color_pixel.y+1) && equat((int)color_pixel.x, (int)color_pixel.y+1) < pow(radius+1,2)){
      color_pixel.y = color_pixel.y+1;
    }    
    // si le pixel de gauche appartient au périmètre
    else if (pow(radius,2) <= equat((int)color_pixel.x-1, (int)color_pixel.y) && equat((int)color_pixel.x-1, (int)color_pixel.y) < pow(radius+1,2)){
      color_pixel.x = color_pixel.x-1;
    }    
    // sinon c'est le pixel en haut à gauche qui appartient au périmètre
    else {
      color_pixel.x = color_pixel.x-1;
      color_pixel.y = color_pixel.y+1;
    }
    
    // afficher le pixel trouvé
    color_octant(color_pixel);
  }
  
  // mettre à jour la nouvelle couleur des pixels sur l'écran
  updatePixels();
}


/**
 * Affiche une sphère en parcourant une grille de voxel. Les voxels sont affichées si ils appartiennent
 * au bord/perimètre/contour de la spère, plus ou moins l'épaisseur.
 */
void sphere(){
  float limite;
  if (cut) limite = radius - 10; 
  else limite = radius + thickness;
  
  for ( int x = (int) (-radius - thickness); x <= (radius + thickness); x++ ) {
    for ( int y = (int) (-radius - thickness); y <= (radius + thickness); y++ ) {
      for (int z = (int) (-radius - thickness); z <= limite; z++ ) {
        if ( (pow(radius,2) <= equat(x,y) + pow((z-centre.z),2)) && (equat(x,y) + pow((z-centre.z),2) < pow(radius+thickness,2))){
          if ( y < 0 )
          fill(255, 0, 0);
          else
          fill(255, 255, 0);
          translate(x*tailleVoxel, y*tailleVoxel, z*tailleVoxel);
          box(tailleVoxel);
          translate(-x*tailleVoxel, -y*tailleVoxel, -z*tailleVoxel);
        }
      }      
    }
  }
}
