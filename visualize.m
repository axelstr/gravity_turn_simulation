function visualize(stage_trajectories, legends)
    hold on
    grid on
    
    s = size(stage_trajectories)
    number_of_stages = s(1)
    for i = 1:number_of_stages
        x = stage_trajectories{i,1};
        y = stage_trajectories{i,2};    
        plot(x/1000,y/1000)
    end
    
    xlabel("x / [km]")
    ylabel("y / [km]")
    title("Trajectory")
    legend(legends)

    print("plot.png", "-dpng", "-r300")
end