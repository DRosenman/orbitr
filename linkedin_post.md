I just published a beta version of orbitr — an R package for N-body orbital mechanics simulation that I've been working on for a while. It's aimed mainly at physics students who want to simulate planetary orbits, binary stars, or chaotic three-body problems in a few lines of R code.

This project is personal for me. When I was at The College of New Jersey, I took an upper-level classical mechanics course that had a computational project on simple orbits. That was the assignment that got me hooked on programming. There was something about watching a physics equation turn into an actual moving system on screen — seeing the math come alive — that made everything click. I went from someone who had never really coded to someone who couldn't stop. That project is basically the reason I ended up in tech.

orbitr is my attempt to make that experience as frictionless as possible for the next student. You set up a system with real physical constants (built in — no Googling "mass of Jupiter in kg"), pick an integrator, and simulate. The output is a tidy tibble you can pipe straight into ggplot2 or plotly. It auto-detects 3D motion and switches to interactive plotly visualizations, has a C++ engine under the hood for speed, and includes examples showing why symplectic integrators matter and what happens when orbits go unstable.

It's still a beta — I need to do more testing before I'd call it production-ready, but it's functional and I'd love feedback: github.com/daverosenman/orbitr

#RStats #OpenSource #Physics #DataScience #ComputationalPhysics
