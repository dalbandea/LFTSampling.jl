#######################
# Interface functions #
#######################

import BDIO: BDIO_read, BDIO_write!

function BDIO.BDIO_read(fb::BDIO.BDIOstream, lftws::AbstractLFT)
    error("No function BDIO_read for $(typeof(lftws))")
end

function BDIO.BDIO_write!(fb::BDIO.BDIOstream, lftws::AbstractLFT)
    error("No function BDIO_write! for $(typeof(lftws))")
end

function save_cnfg_header(fb::BDIO.BDIOstream, lftws::AbstractLFT)
    error("No function save_cnfg_header for $(typeof(lftws))")
end

function read_cnfg_info(fname::String, LFT::Type{L}) where L <: AbstractLFT
    error("No function read_cnfg_info for $(LFT)")
end



#################
# I/O Functions #
#################

"""
    read_next_cnfg(fb::BDIO.BDIOstream, lftws::AbstractLFT)

reads next configuration of BDIO handle `fb` and stores it into `lftws`.
"""
function read_next_cnfg(fb::BDIO.BDIOstream, lftws::AbstractLFT)
    while BDIO.BDIO_get_uinfo(fb) != 8
        BDIO.BDIO_seek!(fb)
    end
    BDIO.BDIO_read(fb, lftws)
end

"""
    save_cnfg(fname::String, lftws::AbstractLFT)

saves model instance `lftws` to BDIO file `fname`. If file does not exist, it
creates one and stores the info in `lftws.params`, and then saves the
configuration. If it does exist, it appends the configuration to the existing
file.
"""
function save_cnfg(fname::String, lftws::AbstractLFT)
    if isfile(fname)
        fb = BDIO.BDIO_open(fname, "a")
    else
        fb = BDIO.BDIO_open(fname, "w", "$(supertype(typeof(lftws))) Configurations")
        BDIO.BDIO_start_record!(fb, BDIO.BDIO_BIN_GENERIC, 1)
        save_cnfg_header(fb, lftws)
        BDIO.BDIO_write_hash!(fb)
    end

    BDIO.BDIO_start_record!(fb, BDIO.BDIO_BIN_F64LE, 8, true)
    BDIO.BDIO_write!(fb,lftws)
    BDIO.BDIO_write_hash!(fb)
    BDIO.BDIO_close!(fb)
end


function read_ensemble(fname::String, LFT::Type{L}) where L <: AbstractLFT
    fb = BDIO.BDIO_open(fname, "r")

    fb, model = read_cnfg_info(fname, LFT)

    nc = count_configs(fname)
    ens = [deepcopy(model) for i in 1:nc]

    for i in 1:nc
        read_next_cnfg(fb, ens[i])
    end

    BDIO.BDIO_close!(fb)

    return ens
end

function count_configs(fname::String)
    fb = BDIO.BDIO_open(fname, "r")
    cont = 0
    while BDIO.BDIO_seek!(fb)
        if BDIO.BDIO_get_uinfo(fb) == 8
            cont += 1
        end
    end
    BDIO.BDIO_close!(fb)
    return cont
end
