# TetrisSolverCpp
Tetris solver made using MacOS Coregraphics' CGWindowListCreateImage to obtain a screenshot. It then derives a tetris board state from the image, before passing the state from Swift to Objective C to a C++ bot program. The bot is a heuristic model with hand-tuned weights. 
  
The model is capible T-spins to a degree, and can play at speeds up to 10pps, limited by the game not itself. 
