# Author: Daryl Harrison

# Enthought library imports.
from enthought.traits.api import Instance, String, List
from enthought.traits.ui.api import View, Item
from enthought.tvtk.api import tvtk

# Local imports.
from enthought.mayavi.core.file_data_source import FileDataSource
from enthought.mayavi.core.pipeline_info import PipelineInfo
from enthought.mayavi.core.traits import DEnum
from os import path

######################################################################
# `TriangleReader` class
######################################################################
class TriangleReader(FileDataSource):
    """
    Reader for the Triangle file format: <http://tetgen.berlios.de/fformats.html>
    Outputs an unstructured grid dataset.
    Open the .face file to construct a grid comprised of triangles.
    Open the .ele file to construct a grid comprised of tetrahedra.
    """

    # The version of this class.  Used for persistence.
    __version__ = 0

    # The VTK dataset to manage.
    grid = Instance(tvtk.UnstructuredGrid, allow_none=False)
    basename = String

    # Information about what this object can produce.
    output_info = PipelineInfo(datasets=['unstructured_grid'],
                               attribute_types=['any'],
                               attributes=['any'])

    point_scalars_name = DEnum(values_name='_point_scalars_list',
                               desc='scalar point data attribute to use')

    cell_scalars_name = DEnum(values_name='_cell_scalars_list',
                               desc='scalar cell data attribute to use')

    ########################################
    # Our view.

    view = View(Item(name='point_scalars_name'),
                Item(name='cell_scalars_name'))

    ########################################
    #

    _cell_scalars_list = List(String)
    _point_scalars_list = List(String)

    def initialize(self, base_file_name):
        split = path.splitext(base_file_name)
        self.basename = split[0]
        extension = split[1]

        self.grid = tvtk.UnstructuredGrid()
        self.grid.points = tvtk.Points()

        self.read_node_file()

        if (extension == '.face'):
            self.read_face_file()
        else:
            self.read_ele_file()

        self.outputs = [self.grid]

        self.name = "Triangle file ("+path.basename(self.basename)+""+extension+")"

    ########################################
    # File reading methods.

    def read_node_file(self):
        f = open(self.basename+'.node')

        points = int(self.read_number(f))
        dimensions = int(self.read_number(f))
        attributes = int(self.read_number(f))
        boundary_marker = bool(self.read_number(f))

        boundary_marker_list = []
        attribute_list = []
        for i in range(attributes):
            attribute_list.append([])

        for i in range(points):
            self.read_number(f) # ignore point number

            coords = []
            for i in range(dimensions):
                coords.append(self.read_number(f))
            self.grid.points.insert_next_point(coords)

            for i in range(attributes):
                attribute_list[i].append(self.read_number(f))

            if (boundary_marker):
                boundary_marker_list.append(int(self.read_number(f)))

        self.add_attributes(attributes, attribute_list, 'point')
        self.add_boundary_marker(boundary_marker, boundary_marker_list, 'point')


    def read_face_file(self):
        # .face file contains triangles
        f = open(self.basename+'.face')

        faces = int(self.read_number(f))
        boundary_marker = bool(self.read_number(f))

        boundary_marker_list = []
        for i in range(faces):
            if (i == 0):
                # Check whether faces are numbered from 0 or 1
                numbered_from = int(self.read_number(f))
            else:
                self.read_number(f) # ignore remaining face numbers
            ids = tvtk.IdList()
            for i in range(3): # nodes per triangle
                ids.insert_next_id(int(self.read_number(f)) - numbered_from)
            self.grid.insert_next_cell(5, ids) # 5 is cell type for triangles

            if (boundary_marker):
                boundary_marker_list.append(int(self.read_number(f)))

        self.add_boundary_marker(boundary_marker, boundary_marker_list, 'cell')


    def read_ele_file(self):
        # .ele file contains tetrahedrons
        f = open(self.basename+'.ele')

        tetrahedra = int(self.read_number(f))
        nodes_per_tetrahedron = int(self.read_number(f))
        attributes = int(self.read_number(f))

        attribute_list = []
        for i in range(attributes):
            attribute_list.append([])

        for i in range(tetrahedra):
            if (i == 0):
                # Check whether tetrahedra are numbered from 0 or 1
                numbered_from = int(self.read_number(f))
            else:
                self.read_number(f) # ignore remaining tetrahedron numbers

            ids = tvtk.IdList()
            for i in range(nodes_per_tetrahedron):
                ids.insert_next_id(int(self.read_number(f)) - numbered_from)
            self.grid.insert_next_cell(10, ids) # 10 is cell type for tetrahedra

            for i in range(attributes):
                attribute_list[i].append(int(self.read_number(f)))

        self.add_attributes(attributes, attribute_list, 'cell')


    def add_attributes(self, attributes, attribute_list, type):
        for i in range(attributes):
            attribute_array_name = 'Attribute '+`i`
            if (type == 'cell'): # .ele file attributes are of type Int
                attribute_array = tvtk.IntArray(name=attribute_array_name)
            else:                # .node file attributes are of type Float
                attribute_array = tvtk.FloatArray(name=attribute_array_name)
            attribute_array.from_array(attribute_list[i])
            eval('self.grid.'+type+'_data').add_array(attribute_array)
            eval('self._'+type+'_scalars_list').append(attribute_array_name)

        if (attributes > 0):
            eval('self.grid.'+type+'_data').set_active_scalars('Attribute 0')


    def add_boundary_marker(self, boundary_marker, boundary_marker_list, type):
        if (boundary_marker):
            boundary_marker_array_name = 'Boundary Marker'
            boundary_marker_array = tvtk.IntArray(name=boundary_marker_array_name)
            boundary_marker_array.from_array(boundary_marker_list)
            eval('self.grid.'+type+'_data').add_array(boundary_marker_array)
            eval('self._'+type+'_scalars_list').append(boundary_marker_array_name)
            eval('self.grid.'+type+'_data').set_active_scalars(boundary_marker_array_name)


    # There might be a better, pre-built method of doing this.
    # Reads in the next number, and returns it as a float.
    def read_number(self, file):
        char = file.read(1)
        while (char == ' ' or char == '\n'):
            char = file.read(1)

        # Start of comment, skip to end of line
        if (char == '#'):
            char = file.read(1)
            while (char != '\n'):
                char = file.read(1)
            file.seek(-1,1)
            return self.read_number(file)
        else:
            number = []
            # Add each digit to array
            while (char != ' ' and char != '\n'):
                number.append(char)
                char = file.read(1)
            file.seek(-1,1)
            return float("".join(number))


    def _cell_scalars_name_changed(self, value):
        self.grid.cell_data.set_active_scalars(value)
        self.data_changed = True


    def _point_scalars_name_changed(self, value):
        self.grid.point_data.set_active_scalars(value)
        self.data_changed = True