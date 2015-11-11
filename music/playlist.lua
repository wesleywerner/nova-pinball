-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- any later version.
   
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
   
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see http://www.gnu.org/licenses/.

-----------------------------------------------------------------------

-- Written by Wesley "keyboard monkey" Werner 2015
-- https://github.com/wesleywerner/

-- This music playlist controls song looping, volume and queuing.

local playlist = {}

playlist.tracks = {
    {
        file="music/nexus_x.it",
        credit="Nexus, by Xaser",
        loop=2,
        volume=0.4,
    },
    {
        file="music/nosotr_x.it",
        credit="Nosotros, by Xaser",
        loop=2,
        volume=0.4,
    },
    {
        file="music/tarvoi_x.it",
        credit="Void of Space, by Xaser",
        loop=4,
        volume=0.4,
    },
    {
        file="music/voxel_x.it",
        credit="voxelbuffer, by Xaser",
        loop=2,
        volume=0.4,
    },
    {
        file="music/zeroph_x.it",
        credit="Zerophine, by Xaser",
        loop=2,
        volume=0.4,
    },
}



return playlist
