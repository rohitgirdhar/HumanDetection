function rnd = getRandom(a, b)
    a = uint32(a);
    b = uint32(b);
    % returns a random integer between a and b, a inclusive
    rnd = a + (b-a)*rand;
    rnd = uint32(rnd);
    if rnd == b
        rnd = a;
    end
