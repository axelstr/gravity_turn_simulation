function visualize(number_of_stages, stage_trajectories, legends, plot_name)
    % visualize Plots the trajectory and velocities of the stages.
    
    subplot(2,1,1)
    hold on
    grid on
    subplot(2,1,2)
    hold on
    grid on
    
    set(0,'defaulttextinterpreter','latex')
    set(0,'DefaultTextFontname', 'CMU Serif')
    set(0,'DefaultAxesFontName', 'CMU Serif')
    
    for n = 1:number_of_stages
        t_list = stage_trajectories{n,1};
        u_list = stage_trajectories{n,2};
        x = u_list(:,3);
        y = u_list(:,4);
        V = u_list(:,1);
        subplot(2,1,1)
        plot(x/1000,y/1000)
        subplot(2,1,2)
        plot(t_list, V/1000);
    end
    
    subplot(2,1,1)
    xlabel("x / [km]")
    ylabel("y / [km]")
    subplot(2,1,2)
    xlabel("t / [s]")
    ylabel("V / [km/s]")
    
    subplot(2,1,1)
    title(plot_name)
    legend(legends, 'location', 'northwest', 'fontname', 'CMU Serif')

    print(plot_name+".png", "-dpng", "-r300")
end