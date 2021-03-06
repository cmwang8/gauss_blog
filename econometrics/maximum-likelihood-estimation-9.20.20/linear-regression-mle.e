new;
library maxlikmt;

// Set random seed for replication
rndseed 9987912;

// Generate data
nobs = 800;
x = rndn(nObs, 1);
beta_real = 1.2;
sigma2 = 4;
y = x*beta_real + sqrt(sigma2)*rndn(nobs, 1);

// Starting values
theta_Start = {0.5, 0.5};

// Perform estimation and print report
call maxlikmtprt(maxlikmt(&lfn, theta_start, y, x));

// Declare 'out' to be a maxlikmtResults
// structure to hold the estimation results
struct maxlikmtResults out;

// Perform estimation, print report and
// store results in 'out'
out = maxlikmtprt(maxlikmt(&lfn2, theta_start, y, x));

// Plot results with original data
struct plotControl myPlot;
myPlot = plotGetDefaults("scatter");

// Set title on the graph
plotSetTitle(&myPlot, "Linear Regression with Maximum Likelihood Estimation", "Arial", 16); 

// Set up the tic style
plotSetTicLabelFont(&myPlot, "Arial", 14);

// Turn on grid
plotSetGrid(&myPlot, "on");

// Turn on the legend
plotSetLegend(&myPlot, "Original"$|"Estimated Line", "top left");
plotSetLegendFont(&myPlot, "Arial", 12);

plotCanvasSize("px", 1200|600);

plotScatter(myPlot, x, y);

// Add trend line
x_sorted = sortc(x, 1);
y_hat = x_sorted*out.par.obj.m[1];

plotAddXY(x_sorted, y_hat);

// Write likelihood function
// No gradients
proc (1) = lfn(theta, y, x, ind);
    local beta_est, sigma2, tmp;
    
    beta_est = theta[1];
    sigma2 = theta[2];
    tmp = (y - x*theta[1])^2;
    
    struct modelResults mm;
    if ind[1];
        mm.function = -1/2*(ln(sigma2) + ln(2*pi) + (y - x*beta_est)^2/sigma2);
    endif;
    
    retp(mm);
endp;
    
// Write likelihood function
// with analytical derivatives

proc (1) = lfn2(theta, y, x, ind);
    local beta_est, sigma2, g1, g2;
    
    beta_est = theta[1];
    sigma2 = theta[2];
    
    struct modelResults mm;
    // Specify likelihood function
    if ind[1];
        mm.function = -1/2*(ln(sigma2) + ln(2*pi) + (y - x*beta_est)^2 / sigma2);
    endif;
    
    // Include gradients
    if ind[2];

       g1 = 1/sigma2 * ((y - x*beta_est) .*x);
       g2 = -1/2 * ((1/sigma2) - (y - x*beta_est)^2 / sigma2^2); 
       
       // Concatenate into a (n observations)x2 matrix. 
       mm.gradient = g1 ~ g2;
    endif;
    
    retp(mm);
endp; 
