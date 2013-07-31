/*
 Copyright (c) 2012 The VCT Project

  This file is part of VoxelConeTracing and is an implementation of
  "Interactive Indirect Illumination Using Voxel Cone Tracing" by Crassin et al

  VoxelConeTracing is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  VoxelConeTracing is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with VoxelConeTracing.  If not, see <http://www.gnu.org/licenses/>.
*/

/*!
* \author Dominik Lazarek (dominik.lazarek@gmail.com)
* \author Andreas Weinmann (andy.weinmann@gmail.com)
*/

#version 430 core

layout(r32ui) uniform readonly uimageBuffer nodePool_color;
layout(r32ui) uniform readonly uimageBuffer levelAddressBuffer;
layout(rgba8) uniform image3D brickPool_color;

layout(r32ui) uniform readonly uimageBuffer nodePool_Neighbour;
layout(r32ui) uniform readonly uimageBuffer nodePool_Neighbour_neg;

uniform uint level;
uniform uint numLevels;
uniform uint axis;

#define NODE_MASK_VALUE 0x3FFFFFFF
#define NODE_NOT_FOUND 0xFFFFFFFF
#define AXIS_X 0
#define AXIS_Y 1
#define AXIS_Z 2
#define AXIS_X_NEG 3
#define AXIS_Y_NEG 4
#define AXIS_Z_NEG 5

uint vec3ToUintXYZ10(uvec3 val) {
    return (uint(val.z) & 0x000003FF)   << 20U
            |(uint(val.y) & 0x000003FF) << 10U 
            |(uint(val.x) & 0x000003FF);
}

uvec3 uintXYZ10ToVec3(uint val) {
    return uvec3(uint((val & 0x000003FF)),
                 uint((val & 0x000FFC00) >> 10U), 
                 uint((val & 0x3FF00000) >> 20U));
}

uint getThreadNode() {
  uint levelStart = imageLoad(levelAddressBuffer, int(level)).x;
  uint nextLevelStart = imageLoad(levelAddressBuffer, int(level + 1)).x;
  memoryBarrier();

  uint index = levelStart + uint(gl_VertexID);

  if (index >= nextLevelStart) {
    return NODE_NOT_FOUND;
  }

  return index;
}

///*
//This shader is launched for every node up to a specific level, so that gl_VertexID 
//exactly matches all node-addresses in a dense octree. */
void main() {
  uint nodeAddress = getThreadNode();
  if(nodeAddress == NODE_NOT_FOUND) {
    return;  // The requested threadID-node does not belong to the current level
  }

  uint neighbourAddress = imageLoad(nodePool_Neighbour, int(nodeAddress)).x;
  memoryBarrier();

  if (neighbourAddress == 0) {
    return; 
  }

  uint neighbourNegAddress = imageLoad(nodePool_Neighbour_neg, int(neighbourAddress)).x;
  
  ivec3 brickAddr = ivec3(uintXYZ10ToVec3(imageLoad(nodePool_color, int(nodeAddress)).x));
  ivec3 nBrickAddr = ivec3(uintXYZ10ToVec3(imageLoad(nodePool_color, int(neighbourAddress)).x));


  
  if (axis == AXIS_X) {
    for (int y = 0; y <= 2; ++y) {
      for (int z = 0; z <= 2; ++z) {
        ivec3 offset = ivec3(2,y,z);
        ivec3 nOffset = ivec3(0,y,z);
        vec4 borderVal = imageLoad(brickPool_color, brickAddr + offset);
        vec4 neighbourBorderVal = imageLoad(brickPool_color, nBrickAddr + nOffset);
        memoryBarrier();

        vec4 finalVal = borderVal + neighbourBorderVal; // TODO: Maybe we need a /2 here and have to use atomics
        //imageStore(brickPool_color, brickAddr + offset, finalVal);
        //imageStore(brickPool_color, brickAddr + offset, finalVal);
        if (neighbourNegAddress != nodeAddress) {
          imageStore(brickPool_color, nBrickAddr + nOffset, vec4(1,0,0,1));
        }
      }
    }
  }

  else if (axis == AXIS_Y) {
    for (int x = 0; x <= 2; ++x) {
      for (int z = 0; z <= 2; ++z) {
        ivec3 offset = ivec3(x,2,z);
        ivec3 nOffset = ivec3(x,0,z);
        vec4 borderVal = imageLoad(brickPool_color, brickAddr + offset);
        vec4 neighbourBorderVal = imageLoad(brickPool_color, nBrickAddr + nOffset);
        memoryBarrier();

        vec4 finalVal = borderVal + neighbourBorderVal; // TODO: Maybe we need a /2 here and have to use atomics
       // imageStore(brickPool_color, brickAddr + offset, finalVal);
        //imageStore(brickPool_color, nBrickAddr + nOffset, finalVal);

        if (neighbourNegAddress != nodeAddress) {
          imageStore(brickPool_color, nBrickAddr + nOffset, vec4(0,1,0,1));
        }
      }
    }
  }

  else if (axis == AXIS_Z) {
    for (int x = 0; x <= 2; ++x) {
      for (int y = 0; y <= 2; ++y) {
        ivec3 offset = ivec3(x,y,2);
        ivec3 nOffset = ivec3(x,y,0);
        vec4 borderVal = imageLoad(brickPool_color, brickAddr + offset);
        vec4 neighbourBorderVal = imageLoad(brickPool_color, nBrickAddr + nOffset);
        memoryBarrier();

        vec4 finalVal = borderVal + neighbourBorderVal; // TODO: Maybe we need a /2 here and have to use atomics
        //imageStore(brickPool_color, brickAddr + offset, finalVal);
        //imageStore(brickPool_color, nBrickAddr + nOffset, finalVal);

       // if (neighbourNegAddress != nodeAddress) {
          imageStore(brickPool_color, nBrickAddr + nOffset, vec4(0,0,1,1));
       // }
      }
    }
  }


  else if (axis == AXIS_X_NEG) {
    for (int y = 0; y <= 2; ++y) {
      for (int z = 0; z <= 2; ++z) {
        ivec3 offset = ivec3(0,y,z);
        ivec3 nOffset = ivec3(2,y,z);
        vec4 borderVal = imageLoad(brickPool_color, brickAddr + offset);
        
        memoryBarrier();
        imageStore(brickPool_color, nBrickAddr + nOffset, borderVal);
      }
    }
  }


  else if (axis == AXIS_Y_NEG) {
    for (int x = 0; x <= 2; ++x) {
      for (int z = 0; z <= 2; ++z) {
        ivec3 offset = ivec3(x,0,z);
        ivec3 nOffset = ivec3(x,2,z);
        vec4 borderVal = imageLoad(brickPool_color, brickAddr + offset);
       
        memoryBarrier();
        imageStore(brickPool_color, nBrickAddr + nOffset, borderVal);
      }
    }
  }


  else if (axis == AXIS_Z_NEG) {
    for (int x = 0; x <= 2; ++x) {
      for (int y = 0; y <= 2; ++y) {
        ivec3 offset = ivec3(x,y,0);
        ivec3 nOffset = ivec3(x,y,2);
        vec4 borderVal = imageLoad(brickPool_color, brickAddr + offset);
        memoryBarrier();

        imageStore(brickPool_color, nBrickAddr + nOffset, borderVal);
      }
    }
  }
  
}